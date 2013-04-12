require "releaf/slug"
require 'releaf/globalize3/fallbacks'
require "releaf/engine"
require "releaf/exceptions"
require "releaf/resources"
require "releaf/boolean_at"


module Releaf
  mattr_accessor :menu
  @@menu = [
   {
      :controller => 'releaf/content',
      :helper => 'releaf_nodes'
    },
    {
      :name => "permissions",
      :sections => [
        {
          :name => "permissions",
          :items =>   %w[releaf/admins releaf/roles]
        }
      ]
    },
    {
      :controller => 'releaf/translations',
      :helper => 'releaf_translation_groups'
    },
  ]

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
  @@controller_list = {}


  class << self
    def setup
      yield self
      build_controller_list
    end

    # build controller list from menu definition
    def build_controller_list
      Releaf.menu.each_with_index do |menu_item, index|
        if menu_item.is_a? String
          Releaf.menu[index] = {:controller => menu_item}
          controller_list[menu_item] = Releaf.menu[index]
        elsif menu_item.is_a? Hash
          # submenu hash
          if menu_item.has_key? :sections
            menu_item[:sections].each_with_index do |submenu_section, submenu_index|
              if submenu_section.has_key? :name and submenu_section.has_key? :items
                submenu_section[:items].each_with_index do |submenu_item, submenu_item_index|
                  if submenu_item.is_a? String
                    submenu_item = {:controller => submenu_item}
                  end

                  submenu_item[:submenu] = menu_item[:name]
                  submenu_section[:items][submenu_item_index] = submenu_item
                  controller_list[submenu_item[:controller]] = submenu_item
                end
              end
            end
          elsif menu_item.has_key? :controller
            controller_list[menu_item[:controller]] = menu_item
          end
        end
      end
    end

    def available_admin_controllers
      controller_list.keys
    end
  end
end
