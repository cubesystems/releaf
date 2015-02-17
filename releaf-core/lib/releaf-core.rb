module Releaf
  require 'releaf/core/engine'
  require 'releaf/core/route_mapper'
  require 'releaf/core/exceptions'
  require 'releaf/core/validation_error_codes'

  mattr_accessor :menu
  @@menu = []

  mattr_accessor :devise_for
  @@devise_for = 'releaf/permissions/user'

  mattr_accessor :mount_location
  @@mount_location = nil

  mattr_accessor :available_locales
  @@available_locales = nil

  mattr_accessor :layout_builder
  @@layout_builder = nil

  mattr_accessor :available_admin_locales
  @@available_admin_locales = nil

  # controllers that must be accessible by user, but are not visible in menu
  # should be added to this list
  mattr_accessor :additional_controllers
  @@additional_controllers = []

  mattr_accessor :access_control_module
  @@access_control_module = nil

  # assets resolver class
  mattr_accessor :assets_resolver
  @@assets_resolver = nil

  # controller list
  mattr_accessor :controller_list
  @@controller_list = {}

  # components
  mattr_accessor :components
  @@components = []

  def self.all_locales
    valid_locales = Releaf.available_locales || []
    valid_locales += Releaf.available_admin_locales || []
    valid_locales += ::I18n.available_locales || []
    valid_locales.map(&:to_s).uniq
  end

  class << self
    def setup
      yield self

      ::I18n.available_locales = Releaf.available_locales
      Releaf.available_admin_locales = Releaf.available_locales if Releaf.available_admin_locales.nil?
      Releaf.menu.map! { |item| normalize_menu_item(item) }

      build_controller_list(Releaf.menu)
      build_controller_list(normalized_additional_controllers)

      self.assets_resolver ||= Releaf::AssetsResolver
      self.components = normalize_components(components)
      self.layout_builder ||= Releaf::Builders::Page::LayoutBuilder
      self.access_control_module ||= Releaf::Permissions
      initialize_components
    end

    def available_controllers
      controller_list.keys
    end

    def initialize_components
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

    private

    def normalized_additional_controllers
      Releaf.additional_controllers.map { |controller| normalize_controller_item(controller) }
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
