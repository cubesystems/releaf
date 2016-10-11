require 'i18n/backend/base'

module Releaf
  module I18nDatabase
    class Backend

      include ::I18n::Backend::Base, ::I18n::Backend::Flatten
      UPDATED_AT_KEY = 'releaf.i18n_database.translations.updated_at'
      DEFAULT_CONFIG = {auto_creation: true, auto_creation_exception_patterns: [/^attributes\./]}
      attr_accessor :translations_cache

      def self.initialize_component
        I18n.backend = I18n::Backend::Chain.new(new, I18n.backend)
      end

      def self.locales_pluralizations
        Releaf.application.config.all_locales.map do|locale|
          TwitterCldr::Formatters::Plurals::Rules.all_for(locale) if TwitterCldr.supported_locale?(locale)
        end.flatten.uniq.compact
      end

      def self.configure_component
        Releaf.application.config.add_configuration(
          Releaf::I18nDatabase::Configuration.new(DEFAULT_CONFIG)
        )
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
      end
    end
  end
end
