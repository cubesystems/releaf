module Releaf
  require 'releaf/core/engine'
  require 'releaf/core/route_mapper'
  require 'releaf/core/exceptions'
  require 'releaf/core/validation_error_codes'
  require 'releaf/core/instance_cache'

  mattr_accessor :menu

  mattr_accessor :devise_for

  mattr_accessor :mount_location

  mattr_accessor :available_locales

  mattr_accessor :layout_builder

  mattr_accessor :available_admin_locales

  # controllers that must be accessible by user, but are not visible in menu
  # should be added to this list
  mattr_accessor :additional_controllers

  mattr_accessor :access_control_module

  # assets resolver class
  mattr_accessor :assets_resolver

  # controller list
  mattr_accessor :controller_list

  # components
  mattr_accessor :components

  def self.all_locales
    valid_locales = Releaf.available_locales || []
    valid_locales += Releaf.available_admin_locales || []
    valid_locales += ::I18n.available_locales || []
    valid_locales.map(&:to_s).uniq
  end

  class << self
    def setup
      yield self

      initialize_defaults
      initialize_locales
      initialize_menu
      initialize_controllers
      initialize_components
    end

    def initialize_locales
      ::I18n.available_locales = available_locales
      self.available_admin_locales = available_locales if available_admin_locales.nil?
    end

    def initialize_menu
      self.menu = menu.map{ |item| normalize_menu_item(item) }
    end

    def initialize_defaults
      default_values.each_pair do|key, value|
        send("#{key}=", value) if send(key).nil?
      end
    end

    def default_values
      {
        menu: [],
        devise_for: 'releaf/permissions/user',
        additional_controllers: [],
        controller_list: {},
        components: [],
        assets_resolver:  Releaf::AssetsResolver,
        layout_builder: Releaf::Builders::Page::LayoutBuilder,
        access_control_module: Releaf::Permissions
      }
    end

    def available_controllers
      controller_list.keys
    end

    def initialize_components
      self.components = normalize_components(components)
      components.each do|component_class|
        component_class.initialize_component if component_class.respond_to? :initialize_component
      end
    end

    def normalize_components(denormalized_components)
      list = []

      denormalized_components.collect do |component_class|
        list += normalize_components(component_class.components) if component_class.respond_to? :components
        # add component itself latter as there can be dependancy to be loadable first
        list << component_class
      end

      list
    end

    def normalized_additional_controllers
      Releaf.additional_controllers.map { |controller| normalize_controller_item(controller) }
    end

    def initialize_controllers
      build_controller_list(Releaf.menu)
      build_controller_list(normalized_additional_controllers)
    end

    # Recursively build list of controllers
    #
    # @param [Array] list config items array
    def build_controller_list(list)
      list.each do |item|
        controller_list[item[:controller]] = item if item.has_key? :controller
        build_controller_list(item[:items]) if item.has_key? :items
      end
    end

    def normalize_controller_item(item_data)
      if item_data.is_a? String
        item = {controller: item_data}
      elsif item_data.is_a? Hash
        item = item_data
      end

      item[:name] = item[:controller] unless item.has_key? :name

      if item.has_key? :helper
        item[:url_helper] = item[:helper].to_sym
      elsif item.has_key? :controller
        item[:url_helper] = item[:controller].gsub('/', '_').to_sym
      end

      item
    end

    # Recursively normalize menu item and subitems
    def normalize_menu_item(item_data)
      item = normalize_controller_item(item_data)
      item[:icon] = "caret-left" if item[:icon].nil?
      item[:items].map! { |subitem| normalize_menu_item(subitem) } if item.has_key?(:items)

      item
    end
  end
end
