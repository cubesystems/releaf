module Releaf::Content
  class Route
    attr_accessor :path, :node, :locale, :node_class, :node_id, :default_controller, :site

    def self.default_controller(node_content_class)
      if node_content_class <= ActionController::Base
        node_content_class.name.underscore.sub(/_controller$/, '')
      else
        node_content_class.name.pluralize.underscore
      end
    end

    # Return node route params which can be used in Rails route options
    #
    # @param method_or_path [String] string with action and controller for route (Ex. home#index)
    # @param options [Hash] options to merge with internally built params. Passed params overrides route params.
    # @return [Hash] route options. Will return at least node "node_id" and "locale" keys.
    def params(method_or_path, options = {})
      method_or_path = method_or_path.to_s
      [
        path_for(method_or_path, options),
        options_for(method_or_path, options)
      ]
    end

    def options_for( method_or_path, options )
      route_options = options.merge({
        to:         controller_and_action_for(method_or_path, options),
        node_class: node_class.name,
        node_id:    node_id.to_s,
        locale:     locale
      })

      route_options[:site] = site if site.present?
      route_options[:as] = name( route_options )

      route_options
    end

    def name( route_options )
      return nil unless route_options[:as].present?

      # prepend :as with locale and site to prevent duplicate route names
      name_parts = [ route_options[:as] ]

      name_parts.unshift( route_options[:locale] ) if route_options[:locale].present?
      name_parts.unshift( route_options[:site] ) if route_options[:site].present?

      name_parts.join('_')
    end

    # Return routes for given class that implement ActsAsNode
    #
    # @param node_class [Class] class name to load related nodes
    # @param node_content_class [Class] class name to load related nodes
    # @param default_controller [String]
    # @return [Array] array of Content::Route objects
    def self.for(node_class, node_content_class, default_controller)
      node_class = node_class.constantize if node_class.is_a? String

      Releaf::Content::BuildRouteObjects.call(
        node_class: node_class,
        node_content_class: node_content_class,
        default_controller: default_controller)
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      []
    end

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
