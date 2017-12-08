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
        subtree = self_with_ancestors(node)

        if subtree.all?(&:active?)
          route = Releaf::Content::Route.new
          route.node_class = node.class
          route.node_id = node.id.to_s
          route.path = build_path(subtree)
          route.locale = subtree.first.locale
          route.default_controller = default_controller
          route.site = Releaf::Content.routing[node.class.name][:site]
          route
        end
      end

      def self_with_ancestors(node)
        nodes.select { |item| item.lft <= node.lft && item.rgt >= node.rgt }.sort_by(&:depth)
      end

      def build_path(subtree)
        path = "/"
        path += subtree.map(&:slug).join("/")
        path += subtree.last.trailing_slash_for_path? ? "/" : ""
        path
      end
    end
  end
end
