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
      rescue StandardError => e
        if file_format_error?(e.class.name, e.message)
          raise UnsupportedFileFormatError
        else
          raise
        end
      end
    end

    def file_format_error?(error_class_name, error_message)
      return true if ['Zip::ZipError','Ole::Storage::FormatError' ].include?(error_class_name)
      error_class_name == 'ArgumentError' && error_message.match("Don't know how to open file").present?
    end

    def translations
      data_rows.map do |row|
        translation_instance(row.first, row[1..-1].map(&:to_s))
      end
    end

    def translation_instance(key, localizations)
      translation = Releaf::I18nDatabase::I18nEntry.where(key: key).first_or_initialize
      maintain_translation_locales(translation, localizations)

      translation
    end

    def maintain_translation_locales(translation, localizations)
      locales.each_with_index do|locale, i|
        locale_translation = translation.i18n_entry_translation.find{|item| item.locale == locale }
        locale_translation ||= translation.i18n_entry_translation.build(locale: locale, text: "")
        locale_translation.text = localizations[i] if localizations[i].present?
      end
    end
  end
end
