module Releaf::Core
  class Configuration
    include Virtus.model(strict: true)
    attribute :components, Array, default: []
    attribute :available_locales, Array, default: []
    attribute :available_admin_locales, Array, default: []
    attribute :assets_resolver_class_name, String, default: 'Releaf::Core::AssetsResolver'
    attribute :layout_builder_class_name, String, default: 'Releaf::Builders::Page::LayoutBuilder'
    attribute :settings_manager, Class
    attribute :menu, Array, default: []
    attribute :mount_location, String, default: ""
    attribute :additional_controllers, Array, default: []

    def components=(_components)
      @components = flatten_components(_components)
      components.each do|component_class|
        component_class.configure_component if component_class.respond_to? :configure_component
      end
    end

    def initialize_components
      components.each do|component_class|
        component_class.initialize_component if component_class.respond_to? :initialize_component
      end
    end

    def add_configuration(configuration)
      configuration_name = configuration.class.name.gsub(/Configuration$/, "").split("::").last.underscore

      self.class.send(:attr_accessor, configuration_name)
      send("#{configuration_name}=", configuration)
    end

    def assets_resolver
      assets_resolver_class_name.constantize
    end

    def initialize_defaults
      self.class.default_values.each_pair do|key, value|
        send("#{key}=", value)
      end
    end

    def initialize_locales
      ::I18n.available_locales = available_locales
      self.available_admin_locales = available_locales if available_admin_locales.empty?
    end

    def all_locales
      @all_locales ||= (available_locales + available_admin_locales).map(&:to_s).uniq
    end

    def flatten_components(raw_components)
      raw_components.each.inject([]) do |list, component_class|
        list += flatten_components(component_class.components) if component_class.respond_to? :components
        list << component_class # add component itself latter as there can be dependancy to be loadable first
      end
    end

    def available_controllers
      @available_controllers ||= controllers.keys
    end

    def controllers
      @controllers ||= extract_controllers(menu + additional_controllers)
    end

    def menu=(value)
      super(self.class.normalize_controllers(value))
    end

    def additional_controllers=(value)
      super(self.class.normalize_controllers(value))
    end

    def extract_controllers(list)
      list.each.inject({}) do |controller_list, item|
        controller_list[item[:controller]] = item if item.has_key? :controller
        controller_list.merge!(extract_controllers(item[:items])) if item.has_key? :items
        controller_list
      end
    end

    def self.normalize_controllers(list)
     list.map{|item| normalize_controller_item(item)}
    end

    def self.normalize_controller_item(item_data)
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

      item[:items] = normalize_controllers(item[:items]) if item.has_key?(:items)

      item
    end
  end
end
