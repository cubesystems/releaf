require 'i18n/backend/base'

module I18n
  module Backend
    class Releaf
      autoload :Translation,      'i18n/backend/releaf/translation'
      autoload :TranslationData,  'i18n/backend/releaf/translation_data'
      autoload :TranslationGroup, 'i18n/backend/releaf/translation_group'


      module Implementation
        include Base, Flatten
        DEFAULT_SCOPE = ['global']

        def store_translations(locale, data, options = {})
        end

        def reload_cache
          I18N_CACHE.clear

          query = Translation.joins(:translation_data)
          query = query.select(["releaf_translations.key", "releaf_translation_data.lang", "releaf_translation_data.localization"])

          query.find_each do |translation|
            I18N_CACHE.write [translation.lang, translation.key], translation.localization
          end
          I18N_CACHE.write('UPDATED_AT', Settings.i18n_updated_at)
        end

        protected



        def check_cache
          return if I18N_CACHE.read('UPDATED_AT') == Settings.i18n_updated_at
          reload_cache
        end

        # Lookup translation from database
        def lookup(locale, key, scope = [], options = {})
          check_cache

          if scope.blank? && key !~ /\./
            scope = DEFAULT_SCOPE
          end

          key = normalize_flat_keys(locale, key, scope, options[:separator])

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
            return result unless result.blank? # found translation in cache
          end while chain.empty? == false

          return nil if I18N_CACHE.read [:missing, [locale, check_key]]
          I18N_CACHE.write([:missing, [locale, check_key]], true) if Translation.where('releaf_translations.key IN (?)', keys_to_check_for_other_locales).exists?

          save_missing_translation(locale, key)
          return nil
        end

        def save_missing_translation(locale, key)
          scope_parts = get_scope key

          tg = TranslationGroup.find_or_create_by_scope(:scope => scope_parts.join('.'))

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

