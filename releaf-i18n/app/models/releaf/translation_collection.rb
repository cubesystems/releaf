module Releaf
  class TranslationCollection
    attr_accessor :collection

    def initialize collection, valid=true
      @collection = collection
      @valid = valid
    end

    def valid?
      @valid
    end

    def self.search lookup_string
      relation = translations_with_localized_data.where(search_statement(lookup_string))
      self.new(relation)
    end

    def self.update params
      collection = []
      deleted_items = []
      valid = true
      ActiveRecord::Base.transaction do
        params.each do |values|
          proxy = Releaf::TranslationProxy.new
          proxy.key = values['key']

          if values["_destroy"] == 'true'
            proxy.destroy
            deleted_items.push proxy
          else
            proxy.localizations = values["localizations"]
            unless proxy.save
              valid = false
            end

            collection.push proxy
          end
        end

        if valid
          Settings.i18n_updated_at = Time.now
        else
          collection += deleted_items
          raise ActiveRecord::Rollback
        end
      end

      self.new(collection, valid)
    end

    private

    def self.translations_with_localized_data
      relation = Translation

      # TODO refactor
      sql_template = 'LEFT OUTER JOIN releaf_translation_data AS %s_data ON %s_data.translation_id = releaf_translations.id AND %s_data.lang = "%s"'
      locales.each do |locale|
        relation = relation.joins(sql_template % ([locale] * 4))
      end
      relation.select(columns_for_select)
    end

    def self.search_statement lookup_string
      lookup_string = lookup_string.try(:strip)
      return nil if lookup_string.blank?
      (['releaf_translations.key'] + localization_column_names).map do |column|
        column_query = lookup_string.split(' ').map do |part|
          "#{column} LIKE '%#{part}%'"
        end.join(' AND ')
        "(#{column_query})"
      end.join(' OR ')
    end

    def self.columns_for_select
      (['releaf_translations.*'] + localization_columns).join(', ')
    end

    def self.localization_columns
      locales.map do |l|
        [
          "%s_data.localization AS %s_localization" % [l, l],
          "%s_data.id AS %s_localization_id" % [l, l]
        ]
      end.flatten
    end

    def self.localization_column_names
      locales.map { |l| "%s_data.localization" % l }
    end

    def self.locales
      valid_locales = ::Releaf.available_locales || []
      valid_locales += ::Releaf.available_admin_locales || []
      valid_locales += ::I18n.available_locales || []

      valid_locales.map(&:to_s).uniq
    end

  end
end
