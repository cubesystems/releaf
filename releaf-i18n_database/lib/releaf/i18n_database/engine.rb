module Releaf::I18nDatabase
  class Engine < ::Rails::Engine
    initializer 'precompile', group: :all do |app|
      app.config.assets.precompile += %w(controllers/releaf/i18n_database/*)
    end
  end
end
