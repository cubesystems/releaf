module Releaf::I18nDatabase
  class ParseSpreadsheetTranslations
    class UnsupportedFileFormatError < StandardError; end
    include Releaf::Service
    attribute :file_path, String
    attribute :extension, String

    def call
      translations
    end

    def rows
      @rows ||= spreadsheet.to_a
    end

    def data_rows
      rows[1..-1].reject{|row| row.first.blank? }
    end

    def locales
      @locales ||= rows.first.reject(&:blank?)
    end

    def spreadsheet
      begin
        Roo::Spreadsheet.open(file_path, extension: extension, file_warning: :ignore)
      rescue ArgumentError => e
        if unsupported_file_content?(e.message)
          raise UnsupportedFileFormatError
        else
          raise
        end
      end
    end

    def unsupported_file_content?(error_message)
      error_message.match("Don't know how to open file").present?
    end

    def translations
      data_rows.map do |row|
        translation_instance(row.first, row[1..-1].map(&:to_s))
      end
    end

    def translation_instance(key, localizations)
      translation = Releaf::I18nDatabase::Translation.where(key: key).first_or_initialize
      maintain_translation_locales(translation, localizations)

      translation
    end

    def maintain_translation_locales(translation, localizations)
      locales.each_with_index do|locale, i|
        translation_data = translation.translation_data.find{|item| item.lang == locale }
        translation_data ||= translation.translation_data.build(lang: locale, localization: "")
        translation_data.localization = localizations[i] if localizations[i].present?
      end
    end
  end
end
