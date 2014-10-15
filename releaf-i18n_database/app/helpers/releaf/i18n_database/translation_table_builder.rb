module Releaf::I18nDatabase
  class TranslationTableBuilder < Releaf::TableBuilder
    def column_names
      [:key] + Releaf.all_locales
    end

    def locale_value(resource, column)
      resource.locale_value(column)
    end

    def cell_format_method(column)
      if Releaf.all_locales.include? column
        :locale_value
      else
        super
      end
    end
  end
end
