require 'i18n/backend/base'

module Releaf
  module I18nDatabase
    class Backend

      include ::I18n::Backend::Base
      include ::I18n::Backend::Flatten
      include ::I18n::Backend::Pluralization

      UPDATED_AT_KEY = 'releaf.i18n_database.translations.updated_at'
      DEFAULT_CONFIG = {
        translation_auto_creation: true,
        translation_auto_creation_patterns: [/.*/],
        translation_auto_creation_exclusion_patterns: [/^attributes\./, /^i18n\./]
      }
      attr_accessor :translations_cache

      def self.initialize_component
        I18n.backend = I18n::Backend::Chain.new(new, I18n.backend)
      end

      def self.locales_pluralizations
        keys = Releaf.application.config.all_locales.map{ |locale| I18n.t(:'i18n.plural.keys', locale: locale) }.flatten
        # always add zero as it skipped for some locales even when there is zero form (lv for example)
        keys << :zero

        keys.uniq
      end

      def self.configure_component
        Releaf.application.config.add_configuration(
          Releaf::I18nDatabase::Configuration.new(DEFAULT_CONFIG)
        )
      end

      def self.reset_cache
        backend_instance.translations_cache = nil
      end

      def self.backend_instance
        if I18n.backend.is_a? I18n::Backend::Chain
          I18n.backend.backends.find{|b| b.is_a?(Releaf::I18nDatabase::Backend) }
        elsif I18n.backend.is_a? Releaf::I18nDatabase::Backend
          I18n.backend
        end
      end

      def self.draw_component_routes router
        router.namespace :releaf, path: nil do
          router.namespace :i18n_database, path: nil do
            router.resources :translations, only: [:index] do
              router.collection do
                router.get :edit
                router.post :update
                router.get :export
                router.post :import
              end
            end
          end
        end
      end

      def translations
        if translations_cache && !translations_cache.expired?
          translations_cache
        else
          self.translations_cache = Releaf::I18nDatabase::TranslationsStore.new
        end
      end

      def self.translations_updated_at
        Releaf::Settings[UPDATED_AT_KEY]
      end

      def self.translations_updated_at= value
        Releaf::Settings[UPDATED_AT_KEY] = value
      end

      def store_translations(locale, data, options = {})
        # pass to simple backend

        I18n.backend.backends.last.store_translations(locale, data, options)
      end

      # Lookup translation from database
      def lookup(locale, key, scope = [], options = {})
        key = normalize_flat_keys(locale, key, scope, options[:separator])

        return if translations.missing?(locale, key)

        result = translations.lookup(locale, key, options)
        translations.missing(locale, key, options) if result.nil?

        result
        # As localization can be used in routes and as routes is loaded also when running `rake db:create`
        # we want to supress those errors and silently return nil as developer/user will get database errors
        # anyway when call to models will be made (let others do this)
      rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
        nil
      end
    end
  end
end
