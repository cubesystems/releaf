require 'i18n/backend/base'

module I18n
  module Backend

    class Releaf
      module Implementation
        include Base, Flatten
        CACHE = {updated_at: nil, translations: {}, missing: {}}

        def reload_cache
          CACHE[:translations] = translations
          CACHE[:missing] = {}
          CACHE[:updated_at] = translations_updated_at
        end

        def translations_updated_at
          Settings.i18n_updated_at
        end


        protected

        # Return all non-empty localizations
        def localization_data
          data_collection = ::Releaf::TranslationData.where("localization != ''").
            joins("LEFT JOIN releaf_translations ON releaf_translations.id=translation_id").
            pluck("CONCAT(lang, '.', releaf_translations.key) As translation_key", "localization")

          Hash[data_collection]
        end

        # Return translation hash for each releaf locales
        def translations
          localization_cache = localization_data

          ::Releaf::Translation.order(:key).pluck("releaf_translations.key").map do |translation_key|
            key_hash(translation_key, localization_cache)
          end.inject(&:deep_merge)
        end

        def cache_lookup keys, locale, options, first_lookup
          result = keys.inject(CACHE[:translations]) { |h, key| h.try(:[], key.to_sym) }

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
          reload_cache if CACHE[:updated_at] != translations_updated_at

          key = normalize_flat_keys(locale, key, scope, options[:separator])
          locale_key = "#{locale}.#{key}"

          # do not process further if key already marked as missing
          return nil if CACHE[:missing].has_key? locale_key

          chain = locale_key.split('.')
          chain_initial_length = chain.length

          while (chain.length > 1) do
            result = cache_lookup(chain, locale, options, chain_initial_length == chain.length)
            return result unless result.blank?

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
          return unless ::Releaf.create_missing_translations

          if options.has_key? :count
            get_all_pluralizations.each do|pluralization|
              ::Releaf::Translation.find_or_create_by(key: "#{key}.#{pluralization}")
            end
          else
            ::Releaf::Translation.find_or_create_by(key: key)
          end
        end

        private

        def key_hash key, localization_cache
          hash = {}

          ::Releaf.available_locales.each do |locale|
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

      include Implementation
    end
  end
end
