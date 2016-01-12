module Releaf::Core
  class Configuration
    attr_accessor :available_locales, :available_admin_locales, :all_locales
    attr_accessor :access_control_module_name, :assets_resolver_class_name, :layout_builder_class_name
    attr_accessor :menu, :devise_for, :mount_location, :components,
      :available_controllers, :additional_controllers, :controllers
    attr_accessor :content_resources

    def configure
      initialize_defaults
      initialize_locales
      initialize_controllers
      initialize_components
    end

    def assets_resolver
      assets_resolver_class_name.constantize
    end

    def access_control_module
      access_control_module_name.constantize
    end

    def initialize_defaults
      self.class.default_values.each_pair do|key, value|
        send("#{key}=", value) if send(key).nil?
      end
    end

    def initialize_locales
      ::I18n.available_locales = available_locales
      self.available_admin_locales = available_locales if available_admin_locales.nil?
      self.all_locales = (available_locales + available_admin_locales).map(&:to_s).uniq
    end

    def initialize_components
      self.components = flatten_components(components)
      components.each do|component_class|
        component_class.initialize_component if component_class.respond_to? :initialize_component
      end
    end

    def flatten_components(raw_components)
      raw_components.each.inject([]) do |list, component_class|
        list += flatten_components(component_class.components) if component_class.respond_to? :components
        list << component_class # add component itself latter as there can be dependancy to be loadable first
      end
    end

    def initialize_controllers
      self.menu = normalize_controllers(menu)
      self.additional_controllers = normalize_controllers(additional_controllers)
      self.controllers = extract_controllers(menu + additional_controllers)
      self.available_controllers = controllers.keys
    end

    def extract_controllers(list)
      list.each.inject({}) do |controller_list, item|
        controller_list[item[:controller]] = item if item.has_key? :controller
        controller_list.merge!(extract_controllers(item[:items])) if item.has_key? :items
        controller_list
      end
    end

    def normalize_controllers(list)
     list.map{|item| normalize_controller_item(item)}
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

      item[:items] = normalize_controllers(item[:items]) if item.has_key?(:items)

      item
    end

    def self.default_values
      {
        menu: [],
        devise_for: 'releaf/permissions/user',
        additional_controllers: [],
        controllers: {},
        components: [],
        assets_resolver_class_name: 'Releaf::Core::AssetsResolver',
        layout_builder_class_name:  'Releaf::Builders::Page::LayoutBuilder',
        access_control_module_name: 'Releaf::Permissions',
        content_resources: { 'Node' => { controller: 'Releaf::Content::NodesController' } }
      }
    end


  end
end
