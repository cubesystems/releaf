module Releaf
  class Controller
    attr_accessor :name, :url_helper, :items, :controller

    def title
      I18n.t(name, scope: "admin.controllers")
    end

    def path
      @path ||= Rails.application.routes.url_helpers.send("#{url_helper}_path")
    end

    def self.configuration(controller_class)
    end

    def self.extract_controllers(list)
      list.each.inject({}) do |controller_list, item|
        controller_list[item[:controller]] = item if item.has_key? :controller
        controller_list.merge!(extract_controllers(item[:items])) if item.has_key? :items
        controller_list
      end
    end

    def self.normalize_controllers(list)
     list.map{|item| normalize_controller_item(item)}
    end

    def self.normalize_controller_item(item_configuration)
      item = {controller: item} if item.is_a? String
      item[:name] ||= item[:controller]

      if item.has_key? :helper
        item[:url_helper] = item[:helper].to_sym
      elsif item.has_key? :controller
        item[:url_helper] = item[:controller].tr('/', '_').to_sym
      elsif item.has_key?(:items)
        item[:items] = normalize_controllers(item[:items])
      end

      instance = Releaf::ControllerConfiguration.new

      item.each_pair do |key, value|
        instance.send("#{key}=", value)
      end

      instance
    end
  end
end

