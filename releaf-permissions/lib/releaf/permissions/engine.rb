module Releaf::Permissions
  class Engine < ::Rails::Engine
    initializer 'releaf_permissions.assets_precompile', group: :all do |app|
      app.config.assets.precompile << "releaf_permissions_manifest.js"
    end
  end
end
