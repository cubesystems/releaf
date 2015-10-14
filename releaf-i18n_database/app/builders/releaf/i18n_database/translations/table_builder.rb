module Releaf::I18nDatabase::Translations
  class TableBuilder < Releaf::Builders::TableBuilder
    def column_names
      [:key] + Releaf.application.config.all_locales
    end

    def head_cell_content(column)
      if Releaf.application.config.all_locales.include? column.to_s
        translate_locale(column)
      else
        super
      end
    end

    def cell_content(resource, column, options)
      tag(:span, super)
    end

    def locale_value(resource, column)
      resource.locale_value(column)
    end

    def cell_format_method(column)
      if Releaf.application.config.all_locales.include? column
        :locale_value
      else
        super
      end
    end
  end
end
