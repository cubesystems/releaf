require 'i18n/backend/base'
# TODO convert to arel
module Releaf
  module I18nDatabase
    class Backend
      include ::I18n::Backend::Base, ::I18n::Backend::Flatten
      CACHE = {updated_at: nil, translations: {}, missing: {}}

      def reload_cache
        CACHE[:translations] = translations || {}
        CACHE[:missing] = {}
        CACHE[:updated_at] = self.class.translations_updated_at
      end

      def reload_cache?
        CACHE[:updated_at] != self.class.translations_updated_at
      end

      def self.translations_updated_at
        Releaf::Settings['releaf.i18n_database.translations.updated_at']
      end

      def self.translations_updated_at= value
        Releaf::Settings['releaf.i18n_database.translations.updated_at'] = value
      end

      def store_translations locale, data, options = {}
        new_hash = {}
        new_hash[locale] = data

        CACHE[:translations].deep_merge!(new_hash)
        CACHE[:missing] = {}
      end

      protected

      # Return all non-empty localizations
      def localization_data
        TranslationData.where("localization <> ''").
          joins("LEFT JOIN releaf_translations ON releaf_translations.id = translation_id").
          pluck("LOWER(CONCAT(lang, '.', releaf_translations.key)) AS translation_key", "localization").
          to_h
      end

      # Return translation hash for each releaf locales
      def translations
        localization_cache = localization_data

        Translation.order(:key).pluck("LOWER(releaf_translations.key)").map do |translation_key|
          key_hash(translation_key, localization_cache)
        end.inject(&:deep_merge)
      end

      def cache_lookup keys, locale, options, first_lookup
        result = keys.inject(CACHE[:translations]) { |h, key| h.is_a?(Hash) && h.try(:[], key.downcase.to_sym) }

        # when non-first match, non-pluralized and hash - return nil
        if !first_lookup && result.is_a?(Hash) && !options.has_key?(:count)
          result = nil
        # return nil as we don't have valid pluralized translation
        elsif result.is_a?(Hash) && options.has_key?(:count) && !valid_pluralized_result?(result, locale, options[:count])
          result = nil
        end

        result
      end

      def valid_pluralized_result? result, locale, count
        valid = false

        if TwitterCldr.supported_locale?(locale)
          rule = TwitterCldr::Formatters::Plurals::Rules.rule_for(count, locale)
          valid = result.has_key? rule
        end

        valid
      end

      # Lookup translation from database
      def lookup(locale, key, scope = [], options = {})
        # reload cache if cache timestamp differs from last translations update
        reload_cache if reload_cache?

        key = normalize_flat_keys(locale, key, scope, options[:separator])
        locale_key = "#{locale}.#{key}"

        # do not process further if key already marked as missing
        return nil if CACHE[:missing].has_key? locale_key

        chain = locale_key.split('.')
        chain_initial_length = chain.length

        while (chain.length > 1) do
          result = cache_lookup(chain, locale, options, chain_initial_length == chain.length)
          return result if result.present?

          # remove second last value
          chain.delete_at(chain.length - 2)
        end

        # mark translation as missing
        CACHE[:missing][locale_key] = true
        create_missing_translation(locale, key, options)

        return nil
      end

      def get_all_pluralizations
        keys = []

        ::Releaf.all_locales.each do|locale|
          if TwitterCldr.supported_locale? locale
            keys += TwitterCldr::Formatters::Plurals::Rules.all_for(locale)
          end
        end

        keys.uniq
      end

      def create_missing_translation(locale, key, options)
        return if Releaf::I18nDatabase.create_missing_translations != true

        if options.has_key?(:count) && options[:create_plurals] == true
          get_all_pluralizations.each do|pluralization|
            Translation.find_or_create_by(key: "#{key}.#{pluralization}")
          end
        else
          Translation.find_or_create_by(key: key)
        end
      end

      private

      def key_hash key, localization_cache
        hash = {}

        ::Releaf.all_locales.each do |locale|
          localized_key = "#{locale}.#{key}"
          locale_hash = locale_hash(localized_key, localization_cache[localized_key])
          hash.merge! locale_hash
        end

        hash
      end

      def locale_hash localized_key, localization
        localized_key.to_s.split(".").reverse.inject(localization) do |value, key|
          {key.to_sym => value}
        end
      end
    end
  end
end
