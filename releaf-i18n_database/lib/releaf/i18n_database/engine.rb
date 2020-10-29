module Releaf::I18nDatabase
  class Engine < ::Rails::Engine
    initializer 'releaf_i18n_database.assets_precompile', group: :all do |app|
      app.config.assets.precompile << "releaf_i18n_database_manifest.js"
    end
  end
end
