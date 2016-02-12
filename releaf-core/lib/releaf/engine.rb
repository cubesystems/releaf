module Releaf
  class Engine < ::Rails::Engine
    initializer 'releaf.assets_precompile', group: :all do |app|
      app.config.assets.precompile += %w(ckeditor/*)
      app.config.assets.precompile += %w(releaf/application.css releaf/controllers/*.css releaf/*.js releaf/*.png releaf/*.gif releaf/*.ico)
    end

    initializer 'releaf.route_mapper', after: 'action_dispatch.prepare_dispatcher' do
      ActionDispatch::Routing::Mapper.send(:include, Releaf::RouteMapper)
    end
  end
end
