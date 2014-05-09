module Releaf
  class TranslationsImporter

    def initialize file_path
      require "roo"
      @excel = Roo::Excelx.new(file_path, file_warning: :ignore)
      @data = []
      @locales = []
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
      # iterate over data
      (2..sheet.last_row).each do |row_no|
        item = {}
        key = nil
        sheet.row(row_no).each_with_index do |cell, i|
          if i == 0
            key = cell
          else
            item[ @locales[ i - 1 ] ] = cell.nil? ? '' : cell
          end
        end

        if key.present?
          translation = Releaf::TranslationProxy.new
          translation.key = key
          translation.localizations = item
          @data << translation
        end
      end
    end
  end
end
