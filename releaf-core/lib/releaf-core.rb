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
require 'virtus'
require 'globalize-accessors'

module Releaf
  module Core
    require 'releaf/core/engine'
    require 'releaf/core/service'
    require 'releaf/core/component'
    require 'releaf/core/settings_ui'
    require 'releaf/core/route_mapper'
    require 'releaf/core/builders_autoload'
    require 'releaf/core/configuration'
    require 'releaf/core/root'
    require 'releaf/core/root/configuration'
    require 'releaf/core/root/default_controller_resolver'
    require 'releaf/core/root/settings_manager'
    require 'releaf/core/application'
    require 'releaf/core/route_mapper'
    require 'releaf/core/exceptions'
    require 'releaf/core/validation_error_codes'

    def self.components
      [Releaf::Core::SettingsUI, Releaf::Core::Root]
    end
  end

  def self.application
    @@application ||= Releaf::Core::Application.new
  end
end
