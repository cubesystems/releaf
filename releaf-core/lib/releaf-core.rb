module Releaf
  require 'releaf/route_mapper'
  require 'releaf/exceptions'
  require 'releaf/validation_error_codes'
  require 'releaf/engine'

  mattr_accessor :menu
  @@menu = [
    {
      :controller => 'releaf/content',
      :helper => 'releaf_nodes'
    },
    {
      :name => "permissions",
      :items =>   %w[releaf/permissions/users releaf/permissions/roles]
    },
    {
      :controller => 'releaf/translations',
    },
  ]

  mattr_accessor :devise_for
  @@devise_for = 'releaf/permissions/user'

  mattr_accessor :layout
  @@layout = "releaf/admin"

  mattr_accessor :load_routes_middleware
  @@load_routes_middleware = true

  mattr_accessor :available_locales
  @@available_locales = nil

  mattr_accessor :available_admin_locales
  @@available_admin_locales = nil

  # controllers that must be accessible by user, but are not visible in menu
  # should be added to this list
  mattr_accessor :additional_controllers
  @@additional_controllers = []

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

      self.components = normalize_components(components)
      initialize_components
    end

    def available_controllers
      controller_list.keys
    end

    def initialize_components
      components.each do|component_class|
        if component_class.respond_to? :initialize_component
          component_class.initialize_component
        end
      end
    end

    def normalize_components denormalized_components
      list = []
      denormalized_components.map do |component_class|
        list << component_class
        if component_class.respond_to? :components
          list += normalize_components(component_class.components)
        end
      end

      list
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
