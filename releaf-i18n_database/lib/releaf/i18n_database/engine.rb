require 'axlsx_rails'

module Releaf::I18nDatabase
  require 'releaf/i18n_database/builders_autoload'
  mattr_accessor :create_missing_translations
  @@create_missing_translations = true

  class Engine < ::Rails::Engine
    initializer 'precompile', group: :all do |app|
      app.config.assets.precompile += %w(releaf/controllers/releaf/i18n_database/*)
    end
  end

  def self.components
    [Releaf::I18nDatabase::HumanizeMissingTranslations]
  end

  def self.initialize_component
    I18n.backend = Releaf::I18nDatabase::Backend.new
    Rails.application.config.middleware.use Releaf::I18nDatabase::CacheReloader
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
end
