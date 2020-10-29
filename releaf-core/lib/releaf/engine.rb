module Releaf
  class Engine < ::Rails::Engine
    initializer 'releaf_core.assets_precompile', group: :all do |app|
      app.config.assets.precompile << "releaf_core_manifest.js"
    end

    initializer 'releaf.route_mapper', after: 'action_dispatch.prepare_dispatcher' do
      ActionDispatch::Routing::Mapper.send(:include, Releaf::RouteMapper)
    end
  end
end
