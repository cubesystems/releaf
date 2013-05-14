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
      # used by easy_globalize3_accessors
      I18n.available_locales = Settings.i18n_locales
    end

    # build controller list from menu definition
    def build_controller_list
      Releaf.menu.each_with_index do |item_data, index|
        item = build_controller_list_item(item_data)

        if item.has_key? :sections
          item[:sections].each_with_index do |submenu_section, submenu_index|
            if submenu_section.has_key? :name and submenu_section.has_key? :items
              submenu_section[:items].each_with_index do |submenu_item_data, submenu_item_index|
                submenu_item = build_controller_list_item(submenu_item_data)

                submenu_item[:submenu] = item[:name]
                submenu_section[:items][submenu_item_index] = submenu_item
                controller_list[submenu_item[:controller]] = submenu_item
              end
            end
          end
        end

        controller_list[item[:controller]] = item if item.has_key? :controller
        Releaf.menu[index] = item
      end
    end

    def available_admin_controllers
      controller_list.keys
    end

    private

    def build_controller_list_item item_data
      if item_data.is_a? String
        item = {:controller => item_data}
      elsif item_data.is_a? Hash
        item = item_data
      end

      unless item.has_key? :name
        item[:name] = item[:controller]
      end

      if item.has_key? :helper
        item[:url_helper] = item[:helper] + "_path"
      elsif item.has_key? :controller
        item[:url_helper] = item[:controller].gsub('/', '_') + "_path"
      end

      return item
    end

  end
end
