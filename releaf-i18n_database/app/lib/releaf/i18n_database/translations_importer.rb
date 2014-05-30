module Releaf::I18nDatabase
  class TranslationsImporter
    class UnsupportedFileFormatError < StandardError; end

    def initialize file_path, file_extension
      require "roo"
      begin
        @excel = Roo::Spreadsheet.open(file_path, file_warning: :ignore, extension: file_extension)
        @data = []
        @locales = []
      rescue ArgumentError => e
        error_string = "Don't know how to open file"
        if e.message.match(error_string)
          raise UnsupportedFileFormatError
        else
          raise
        end
      end
    end

    def parsed_output
      @excel.each_with_pagename do |name, sheet|
        detect_sheet_locales(sheet)
        parse_sheet(sheet)
      end

      @data
    end

    def detect_sheet_locales sheet
      sheet.row(1).each_with_index do |cell, i|
        if i > 0
          @locales << cell
        end
      end
    end

    def parse_sheet sheet
      (2..sheet.last_row).each do |row_no|
        key = sheet.row(row_no)[0]
        localizations = sheet.row(row_no)[1..-1]
        if key.present?
          @data << load_translation(key, localizations)
        end
      end
    end

    def load_translation key, localizations
      translation = Translation.where(key: key).first_or_initialize
      translation.key = key

      localizations.each_with_index do |localization, i|
        load_translation_data(translation, @locales[i], localization)
      end

      translation
    end

    def load_translation_data translation, locale, localization
      translation_data = translation.translation_data.find{ |x| x.lang == locale }
      value = localization.nil? ? '' : localization

      # replace existing locale value only if new one is not blank
      if translation_data && !value.blank?
        translation_data.localization = value
      # always assign value for new locale
      elsif translation_data.nil?
        translation_data = translation.translation_data.build(lang: locale, localization: value)
      end
    end
  end
end
