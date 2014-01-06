module Releaf
  require 'releaf/route_mapper'
  require 'releaf/exceptions'
  require 'releaf/acts_as_node'
  require 'releaf/validation_error_codes'
  require 'releaf/engine'
  require 'releaf/richtext_attachments'
  require 'releaf/template_field_type_mapper'
  require 'releaf/resource_validator'
  require 'releaf/template_filter'
  require 'releaf/resource_finder'

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

  mattr_accessor :load_routes_middleware
  @@load_routes_middleware = true

  mattr_accessor :create_missing_translations
  @@create_missing_translations = true

  mattr_accessor :available_locales
  @@available_locales = nil

  mattr_accessor :available_admin_locales
  @@available_admin_locales = nil

  # controllers that must be accessible by admin, but are not visible in menu
  # should be added to this list
  mattr_accessor :additional_controllers
  @@additional_controllers = []

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

      Releaf.menu.map! { |item| normalize_menu_item(item) }

      build_controller_list(Releaf.menu)
      build_controller_list(normalized_additional_controllers)
    end

    def available_controllers
      controller_list.keys
    end

    private

    def normalized_additional_controllers
      Releaf.additional_controllers.map { |c| normalize_controller_item c }
    end

    # Recursively build list of controllers
    #
    # @param [Array] menu config items array
    def build_controller_list list
      list.each do |item|
        controller_list[item[:controller]] = item if item.has_key? :controller
        if item.has_key?(:items)
          build_controller_list(item[:items])
        end
      end
    end

    def normalize_controller_item item_data
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

    # Recursively normalize menu item and subitems
    def normalize_menu_item item_data
      item = normalize_controller_item item_data

      if item.has_key?(:items)
        item[:items].map! { |subitem| normalize_menu_item(subitem) }
      end

      return item
    end
  end
end
