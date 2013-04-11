require "releaf/slug"
require 'releaf/globalize3/fallbacks'
require "releaf/engine"
require "releaf/exceptions"
require "releaf/resources"
require "releaf/boolean_at"


module Releaf
  mattr_accessor :menu
  @@menu = [
    'releaf/content',
    {
      :permissions => [
        {:permissions =>   %w[releaf/admins releaf/roles]}
      ]
    },
    'releaf/translations'
  ]

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

  mattr_accessor :yui_js_url
  # @@yui_js_url = 'http://yui.yahooapis.com/3.9.0/build/yui/yui-min.js'
  @@yui_js_url = 'http://yui.yahooapis.com/3.9.0/build/yui-base/yui-base-min.js'
  # @@yui_js_url = 'http://yui.yahooapis.com/3.9.0/build/yui-core/yui-core-min.js'

  # http://yuilibrary.com/yui/docs/api/classes/config.html
  mattr_accessor :yui_config
  @@yui_config = {}

  # controller list
  mattr_accessor :controller_list
  @@controller_list = []


  class << self
    def setup
      yield self
      build_controller_list
    end

    # build controller list from menu definition
    def build_controller_list

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
