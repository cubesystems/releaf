module Releaf
  module Content
    class BuildRouteObjects
      include Releaf::Service
      include Releaf::InstanceCache

      cache_instance_method :nodes

      attribute :node_class
      attribute :node_content_class
      attribute :default_controller

      def call
        content_nodes.map { |node| build_route_object(node) }.compact
      end

      def content_nodes
        nodes.select { |item| item.content_type == node_content_class.name }
      end

      def nodes
        node_class.all
      end

      def build_route_object(node)
        node.preloaded_self_and_ancestors = self_and_ancestors(node)

        if node.available?
          route = Releaf::Content::Route.new
          route.node_class = node.class
          route.node_id = node.id.to_s
          route.path = build_path(node)
          route.locale = node.self_and_ancestors_array.first.locale
          route.default_controller = default_controller
          route.site = Releaf::Content.routing[node.class.name][:site]
          route
        end
      end

      def self_and_ancestors(node)
        nodes.select { |item| item.lft <= node.lft && item.rgt >= node.rgt }.sort_by(&:depth)
      end

      def build_path(node)
        path = "/"
        path += node.self_and_ancestors_array.map(&:slug).join("/")
        path += node.trailing_slash_for_path? ? "/" : ""
        path
      end
    end
  end
end
