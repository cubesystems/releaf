module Releaf::I18nDatabase::Translations
  class TableBuilder < Releaf::Builders::TableBuilder
    def column_names
      [:key] + Releaf.all_locales
    end

    def head_cell_content(column)
      if Releaf.all_locales.include? column.to_s
        tag(:span) do
          translate_locale(column)
        end
      else
        super
      end
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
