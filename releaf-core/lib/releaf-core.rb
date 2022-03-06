require 'ckeditor_rails'
require 'ckeditor-rails/engine' # remove when ckeditor rails 7 compat has been released
require 'will_paginate'
require 'font-awesome-rails'
require 'haml'
require 'haml-rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'vanilla-ujs'
require 'acts_as_list'
require 'dragonfly'
require 'globalize'
require 'virtus'
require 'sassc-rails'

module Releaf
  module Core
    require 'releaf/engine'
    require 'releaf/service'
    require 'releaf/instance_cache'
    require 'releaf/component'
    require 'releaf/settings'
    require 'releaf/settings_ui'
    require 'releaf/settings/register'
    require 'releaf/route_mapper'
    require 'releaf/configuration'
    require 'releaf/controller_definition'
    require 'releaf/controller_group_definition'
    require 'releaf/root'
    require 'releaf/root/configuration'
    require 'releaf/root/default_controller_resolver'
    require 'releaf/root/settings_manager'
    require 'releaf/application'
    require 'releaf/route_mapper'
    require 'releaf/exceptions'
    require 'releaf/core_ext/array/reorder'
    require 'releaf/rails_ext/globalize-accessors'

    def self.components
      [Releaf::SettingsUI, Releaf::Root]
    end
  end

  def self.application
    @@application ||= Releaf::Application.new
  end
end
