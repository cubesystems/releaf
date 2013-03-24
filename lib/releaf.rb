require "releaf/slug"
require 'releaf/globalize3/fallbacks'
require "releaf/engine"
require "releaf/exceptions"
require "releaf/resources"
require "releaf/boolean_at"


module Releaf
  mattr_accessor :main_menu
  @@main_menu = [
    'releaf/content',
    '*permissions',
    'releaf/translations'
  ]

  mattr_accessor :base_menu
  @@base_menu = {
    '*permissions' => [
      ['permissions',   %w[releaf/admins releaf/roles]],
    ]
  }

  mattr_accessor :devise_for
  @@devise_for = 'releaf/admin'

  mattr_accessor :layout
  @@layout = "releaf/admin"

  class << self
    def setup
      yield self
    end

    def available_admin_controllers
      controllers = []

      Releaf.main_menu.each do |menu_item|
        if !menu_item.start_with?('*')
          controllers << menu_item
        end
      end

      Releaf.base_menu.each_pair do |k, menu_section|
        menu_section.each do |menu_group|
          controllers.concat(menu_group[1])
        end
      end

      return controllers
    end
  end
end
