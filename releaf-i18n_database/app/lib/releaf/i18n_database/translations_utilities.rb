module Releaf::I18nDatabase
  class TranslationsUtilities

    def self.resource_class
      Releaf::I18nDatabase::Translation
    end

    def self.search(collection, search_string, only_blank)
      collection = filter_by_text(collection, search_string) if search_string.present?
      collection = filter_only_blank_translations(collection) if only_blank == true
      collection
    end

    def self.filter_only_blank_translations(collection)
      blank_where_collection = resource_class
      search_columns.each do |column|
        blank_where_collection = blank_where_collection.where(column.eq('').or(column.eq(nil)))
      end

      collection.where(blank_where_collection.where_values.reduce(:or))
    end

    def self.filter_by_text(collection, lookup_string)
      sql = search_columns.map do |column|
        lookup_string.split(' ').map do |part|
          column.matches("%#{escape_lookup_string(part)}%")
        end.inject(&:and)
      end.map{|column_search| "(#{column_search.to_sql})" }.join(' OR ')

      collection.where(sql)
    end

    def self.search_columns
      [resource_class.arel_table[:key]] + Releaf.application.config.all_locales.map do|locale|
        resource_class.arel_table.alias("#{locale}_data")[:localization]
      end
    end

    def self.escape_lookup_string(string)
      escapable_chars = %w{% _}
      result = string.dup

      escapable_chars.each do |char|
        result.gsub! char, '\\' + char
      end

      result
    end

    def self.locale_tables
      Releaf.application.config.all_locales.map do|locale|
        resource_class.arel_table.alias("#{locale}_data")
      end
    end

    def self.load_translation(key, localizations)
      translation = Releaf::I18nDatabase::Translation.where(key: key).first_or_initialize
      translation.key = key

      localizations.each_pair do |locale, localization|
        load_translation_data(translation, locale, localization)
      end

      translation
    end

    def self.load_translation_data(translation, locale, localization)
      translation_data = translation.translation_data.find{ |x| x.lang == locale }
      # replace existing locale value only if new one is not blank
      if translation_data
        translation_data.localization = localization
      # always assign value for new locale
      elsif translation_data.nil?
        translation_data = translation.translation_data.build(lang: locale, localization: localization)
      end

      translation_data
    end

    def self.include_local_tables(collection)
      sql = "
      LEFT OUTER JOIN
        releaf_translation_data AS %s_data ON %s_data.translation_id = releaf_translations.id AND %s_data.lang = '%s'
      "

      Releaf.application.config.all_locales.each do |locale|
        collection = collection.joins(sql % ([locale] * 4))
      end

      collection.select(columns_for_select).order(:key)
    end

    def self.columns_for_select
      (['releaf_translations.*'] + localization_columns).join(', ')
    end

    def self.localization_columns
      Releaf.application.config.all_locales.map do |l|
        [
          "%s_data.localization AS %s_localization" % [l, l],
          "%s_data.id AS %s_localization_id" % [l, l]
        ]
      end.flatten
    end
  end
end
