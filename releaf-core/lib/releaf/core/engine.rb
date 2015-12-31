require 'gravatar_image_tag'
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
  require 'releaf/core/settings_ui_component'
  require 'releaf/core/route_mapper'
  require 'releaf/core/builders_autoload'

  def self.components
    [Releaf::Core::SettingsUIComponent]
  end

  class Engine < ::Rails::Engine
    initializer 'precompile', group: :all do |app|
      app.config.assets.precompile += %w(ckeditor/*)
      app.config.assets.precompile += %w(releaf/*)
    end
  end

  ActionDispatch::Routing::Mapper.send(:include, Releaf::Core::RouteMapper)
end
