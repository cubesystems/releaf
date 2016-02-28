module Releaf::I18nDatabase
  class TranslationsUtilities

    def self.search(collection, search_string, only_blank)
      collection = filter_by_text(collection, search_string) if search_string.present?
      collection = filter_only_blank_translations(collection) if only_blank == true
      collection
    end

    def self.filter_only_blank_translations(collection)
      blank_where_collection = Releaf::I18nDatabase::I18nEntry
      search_columns.each do |column|
        blank_where_collection = blank_where_collection.where(column.eq('').or(column.eq(nil)))
      end

      collection.where(blank_where_collection.where_values.reduce(:or))
    end

    def self.filter_by_text(collection, lookup_string)
      sql = column_searches(lookup_string).map{|column_search| "(#{column_search})" }.join(' OR ')
      collection.where(sql)
    end

    def self.column_searches(lookup_string)
      search_columns.map do |column|
        lookup_string.split(' ').map do |part|
          column.matches("%#{escape_search_string(part)}%")
        end.inject(&:and).to_sql
      end
    end

    def self.search_columns
      [Releaf::I18nDatabase::I18nEntry.arel_table[:key]] + locale_tables.map{|_locale, table| table[:text] }
    end

    def self.escape_search_string(string)
      string.gsub(/([%|_])/){|r| "\\#{r}" }
    end

    def self.locale_tables
      Releaf.application.config.all_locales.inject({}) do|h, locale|
        h.update(locale => Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("#{locale}_data"))
      end
    end

    def self.include_localizations(collection)
      collection.select(localization_include_selects).joins(localization_include_joins)
    end

    def self.localization_include_joins
      locale_tables.map do |locale, table|
        "LEFT JOIN #{table.relation.name} AS #{table.name} ON #{locale}_data.i18n_entry_id = releaf_i18n_entries.id AND #{locale}_data.locale = '#{locale}'"
      end
    end

    def self.localization_include_selects
      (['releaf_i18n_entries.*'] + localization_include_locales_columns).join(', ')
    end

    def self.localization_include_locales_columns
      locale_tables.map do |locale, table|
        ["#{table.name}.text AS #{locale}_localization", "#{table.name}.id AS #{locale}_localization_id"]
      end.flatten
    end
  end
end
