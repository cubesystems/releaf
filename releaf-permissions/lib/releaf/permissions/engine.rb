module Releaf::Permissions
  class Engine < ::Rails::Engine
    initializer 'precompile', group: :all do |app|
      app.config.assets.precompile += %w(controllers/releaf/permissions/*)
    end
  end
end
