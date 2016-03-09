module Releaf
  class Configuration
    include Virtus.model(strict: true)
    attribute :components, Array, default: []
    attribute :available_locales, Array, default: []
    attribute :available_admin_locales, Array, default: []
    attribute :layout_builder_class_name, String, default: 'Releaf::Builders::Page::LayoutBuilder'
    attribute :settings_manager, Class
    attribute :menu, Array, default: []
    attribute :mount_location, String, default: ""
    attribute :additional_controllers, Array, default: []

    def components=(value)
      super(flatten_components(value))
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
        if item.respond_to? :controllers
          controller_list.merge!(extract_controllers(item.controllers))
        else
          controller_list[item.controller_name] = item
        end

        controller_list
      end
    end

    def self.normalize_controllers(list)
      list.map do |item|
        if item.is_a?(Hash) && item.has_key?(:items)
          ControllerGroupDefinition.new(item)
        elsif item.is_a?(Hash) || item.is_a?(String)
          ControllerDefinition.new(item)
        else
          item
        end
      end
    end
  end
end
