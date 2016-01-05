module Releaf::Content
  class Route
    attr_accessor :path, :node, :locale, :node_id, :default_controller

    def self.node_class
      # TODO model should be configurable
      ::Node
    end

    def self.node_class_default_controller(node_class)
      if node_class <= ActionController::Base
        node_class.name.underscore.sub(/_controller$/, '')
      else
        node_class.name.pluralize.underscore
      end
    end

    # Return node route params which can be used in Rails route options
    #
    # @param method_or_path [String] string with action and controller for route (Ex. home#index)
    # @param options [Hash] options to merge with internally built params. Passed params overrides route params.
    # @return [Hash] route options. Will return at least node "node_id" and "locale" keys.
    def params(method_or_path, options = {})
      method_or_path = method_or_path.to_s
      action_path = path_for(method_or_path, options)
      options[:to] = controller_and_action_for(method_or_path, options)

      route_options = options.merge({
        node_id: node_id.to_s,
        locale: locale,
      })

      # normalize as with locale
      if locale.present? && route_options[:as].present?
        route_options[:as] = "#{locale}_#{route_options[:as]}"
      end

      [action_path, route_options]
    end

    # Return routes for given class that implement ActsAsNode
    #
    # @param class_name [Class] class name to load related nodes
    # @param default_controller [String]
    # @return [Array] array of Content::Route objects
    def self.for(content_type, default_controller)
      node_class.where(content_type: content_type).each.inject([]) do |routes, node|
        routes << build_route_object(node, default_controller) if node.available?
        routes
      end
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      []
    end

    # Build Content::Route from Node object
    def self.build_route_object(node, default_controller)
      route = new
      route.node_id = node.id.to_s
      route.path = node.path
      route.locale = node.root.locale
      route.default_controller = default_controller

      route
    end

    private

    def path_for(method_or_path, options)
      if method_or_path.include?('#')
        path
      elsif options.key?(:to)
        "#{path}/#{method_or_path}"
      else
        path
      end
    end

    def controller_and_action_for(method_or_path, options)
      if method_or_path.start_with?('#')
        "#{default_controller}#{method_or_path}"
      elsif method_or_path.include?('#')
        method_or_path
      elsif options[:to].try!(:start_with?, '#')
        "#{default_controller}#{options[:to]}"
      elsif options[:to].try!(:include?, '#')
        options[:to]
      else
        "#{default_controller}##{method_or_path}"
      end
    end

  end
end
