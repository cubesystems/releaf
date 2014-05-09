module Releaf
  class TranslationsExporter

    def initialize collection
      require "axlsx"

      # construct xlsx file
      @excel = Axlsx::Package.new
      # Numbers requires this
      @excel.use_shared_strings = true

      add_translations_to_workbook(collection)
    end

    def add_translations_to_workbook(collection)
      sheet = @excel.workbook.add_worksheet(name: 'localization')

      # title row
      row = [ '' ]
      Releaf.all_locales.each do |locale|
        row.push(locale)
      end

      xls_row = sheet.add_row(row)

      collection.each do |translation|
        row = [ translation.key ]
        Releaf.all_locales.each do |locale|
          row.push(translation.localizations[locale])
        end

        xls_row = sheet.add_row(row)
      end
    end

    def output_as_string
      outstrio = StringIO.new
      outstrio.write(@excel.to_stream.read)
      outstrio.string
    end
  end
end
