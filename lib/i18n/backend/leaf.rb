require 'i18n/backend/base'

module I18n
  module Backend
    class Leaf
      autoload :Translation,      'i18n/backend/leaf/translation'
      autoload :TranslationData,  'i18n/backend/leaf/translation_data'
      autoload :TranslationGroup, 'i18n/backend/leaf/translation_group'


      module Implementation
        include Base, Flatten
        DEFAULT_SCOPE = ['global']

        def available_locales
          TranslationData.available_locales
        rescue ::ActiveRecord::StatementInvalid
          []
        end

        def store_translations(locale, data, options = {})
        end

        def reload_cache
          I18N_CACHE.clear
          Translation.get_translated.find_each do |translation|
            I18N_CACHE.write [translation.lang, translation.key], translation.localization
          end
          I18N_CACHE.write('UPDATED_AT', Settings.i18n_updated_at)
        end

        protected



        def check_cache
          return if I18N_CACHE.read('UPDATED_AT').nil? == false && I18N_CACHE.read('UPDATED_AT') == Settings.i18n_updated_at
          reload_cache
        end

        # Lookup translation from database
        def lookup(locale, key, scope = [], options = {})
          if scope.blank?
            scope = DEFAULT_SCOPE
          end

          key = normalize_flat_keys(locale, key, scope, options[:separator])
          group = key.split('.')[0...-1].join('.')

          chain = key.split('.')
          search_key = chain[-1]
          keys_to_check_for_other_locales = []

          begin
            chain.pop
            check_key = (chain + [search_key]).join('.')
            result = I18N_CACHE.read [locale, check_key]

            keys_to_check_for_other_locales.push check_key

            next if result.nil? # nothing in cache was found
            return nil if result == false # found nil translaiton in cache
            return result unless result.blank? #if result.blank? == false # found translation in cache
          end while chain.empty? == false

          return nil if Translation.where('leaf_translations.key IN (?)', keys_to_check_for_other_locales).exists?

          save_missing_translation(locale, key)
          return nil
        rescue ::ActiveRecord::StatementInvalid
          # is the translations table missing?
          nil
        end

        def save_missing_translation(locale, key)
          scope_parts = get_scope key

          tg = nil
          while !scope_parts.empty?
            j_scope = scope_parts.join('.')
            ntg = TranslationGroup.find_or_create_by_scope(:scope => j_scope)
            tg ||= ntg
            scope_parts.pop
          end

          tg.translations.find_or_create_by_key(key)
          I18N_CACHE.write [locale, key], false
        end

        def get_scope key
          scope = key.split('.')[0...-1]
          return scope unless scope.empty?
          return DEFAULT_SCOPE
        end

      end

      include Implementation
    end
  end
end

