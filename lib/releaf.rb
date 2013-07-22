require "releaf/slug"
require 'releaf/globalize3/fallbacks'
require "releaf/engine"
require "releaf/exceptions"
require "releaf/resources"
require "releaf/boolean_at"
require "releaf/input_locales"


module Releaf
  mattr_accessor :menu
  @@menu = [
   {
      :controller => 'releaf/content',
      :helper => 'releaf_nodes'
    },
    {
      :name => "permissions",
      :items =>   %w[releaf/admins releaf/roles]
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

  mattr_accessor :use_releaf_i18n
  @@use_releaf_i18n = true

  mattr_accessor :available_locales
  @@available_locales = nil

  mattr_accessor :available_admin_locales
  @@available_admin_locales = nil

  # controller list
  mattr_accessor :controller_list
  @@controller_list = {}


  class << self
    def setup
      yield self

      I18n.available_locales = Releaf.available_locales
      Releaf.available_admin_locales = Releaf.available_locales if Releaf.available_admin_locales.nil?

      if Releaf.use_releaf_i18n == true
        require 'i18n/releaf'
      end

      build_controller_list
    end

    # build controller list from menu definition
    def build_controller_list
      Releaf.menu.each_with_index do |item_data, index|
        item = build_controller_list_item(item_data)

        if item.has_key? :items
          if item.has_key? :name and item.has_key? :items
            item[:items].each_with_index do |submenu_item_data, submenu_item_index|
              submenu_item = build_controller_list_item(submenu_item_data)

              submenu_item[:submenu] = item[:name]
              item[:items][submenu_item_index] = submenu_item
              controller_list[submenu_item[:controller]] = submenu_item
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
