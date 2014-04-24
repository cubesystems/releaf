require 'i18n/backend/base'
I18N_CACHE = ActiveSupport::Cache::MemoryStore.new

module I18n
  module Backend

    class Releaf
      autoload :Translation,      'i18n/backend/releaf/translation'
      autoload :TranslationData,  'i18n/backend/releaf/translation_data'
      autoload :TranslationGroup, 'i18n/backend/releaf/translation_group'


      module Implementation
        include Base, Flatten
        DEFAULT_SCOPE = ['global']

        def reload_cache
          I18N_CACHE.clear

          keys = ["releaf_translations.key", "releaf_translation_data.lang", "releaf_translation_data.localization"]
          Translation.joins(:translation_data).select(keys).each do |translation|
            I18N_CACHE.write [translation.lang, translation.key], translation.localization
          end

          I18N_CACHE.write('UPDATED_AT', Settings.i18n_updated_at)
        end

        protected

        # Lookup translation from database
        def lookup(locale, key, scope = [], options = {})
          # reload cache if cache timestamp differs from last translations update
          reload_cache if I18N_CACHE.read('UPDATED_AT') != Settings.i18n_updated_at

          if scope.blank? && key !~ /\./
            scope = DEFAULT_SCOPE
          end

          key = normalize_flat_keys(locale, key, scope, options[:separator])
          # do not process further if key already marked as missing
          return nil if I18N_CACHE.read([:missing, [locale, key]])

          chain = key.split('.')
          search_key = chain.pop
          keys_to_check_for_other_locales = []

          while (chain.length > 0) do
            # build full translation key with current scope
            check_key = (chain + [search_key]).join('.')
            # read value from 118N cache
            result = I18N_CACHE.read([locale, check_key])
            # store key for checking in other locales
            keys_to_check_for_other_locales.push check_key

            # remove chain last value
            chain.pop

            # go to next scope as translation do not exist
            next if result.nil?
            # return only if translation is not blank
            return result unless result.blank?
          end

          # mark translation as missing
          I18N_CACHE.write([:missing, [locale, key]], true)

          if ::Releaf.create_missing_translations
            # do not create new translation if exists in database in any scope
            unless Translation.where('releaf_translations.key IN (?)', keys_to_check_for_other_locales).exists?
              save_missing_translation(locale, key)
            end
          end

          return nil
        end

        def save_missing_translation(locale, key)
          scope_parts = key.split('.')[0...-1]
          group = TranslationGroup.find_or_create_by(scope: scope_parts.join('.'))

          group.translations.find_or_create_by(key: key)
          I18N_CACHE.write [locale, key], false
        end
      end

      include Implementation
    end
  end
end
