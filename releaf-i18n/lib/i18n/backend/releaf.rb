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

        def translation_data
          data_collection = ::Releaf::TranslationData.where("localization != ''").
            joins("LEFT JOIN releaf_translations ON releaf_translations.id=translation_id").
            pluck("CONCAT(lang, '.', releaf_translations.key) As translation_key", "localization")

          Hash[data_collection]
        end

        def translations
          data_cache = translation_data

          ::Releaf::Translation.order(:key).pluck("releaf_translations.key").map do |translation_key|
            translation_hash = {}

            ::Releaf.available_locales.each do|locale|
              localized_key = "#{locale}.#{translation_key}"
              locale_hash = localized_key.to_s.split(".").reverse.inject(data_cache[localized_key]) do |value, key|
                {key.to_sym => value}
              end

              translation_hash.merge!(locale_hash)
            end

            translation_hash
          end.inject(&:deep_merge)
        end

        def cache_lookup keys
          keys.inject(CACHE[:translations]) { |h, key| h.try(:[], key.to_sym) }
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

          while (chain.length > 1) do
            result = cache_lookup(chain)
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
      end

      include Implementation
    end
  end
end
