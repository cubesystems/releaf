require 'jquery-cookie-rails'
require 'rails-settings-cached'
require 'ckeditor_rails'
require 'will_paginate'
require 'font-awesome-rails'
require 'haml'
require 'haml-rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'acts_as_list'
require 'dragonfly'
require 'globalize'
require 'globalize-accessors'

module Releaf::Core
  require 'releaf/core/component'
  require 'releaf/core/settings_ui'
  require 'releaf/core/route_mapper'
  require 'releaf/core/builders_autoload'

  def self.components
    [Releaf::Core::SettingsUI]
  end

  class Engine < ::Rails::Engine
    initializer 'releaf.assets_precompile', group: :all do |app|
      app.config.assets.precompile += %w(ckeditor/*)
      app.config.assets.precompile += %w(releaf/application.css releaf/controllers/*.css releaf/*.js releaf/*.png releaf/*.gif releaf/*.ico)
    end

    initializer 'releaf.route_mapper',
      after: 'action_dispatch.prepare_dispatcher' do |app|
      ActionDispatch::Routing::Mapper.send(:include, Releaf::Core::RouteMapper)
    end
  end

end
