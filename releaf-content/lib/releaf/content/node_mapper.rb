module Releaf::Content
  module NodeMapper
    attr_accessor :default_node_class

    def node_routes_for(
      node_content_class,
      controller: Releaf::Content::Route.default_controller(node_content_class),
      node_class: default_node_class || Releaf::Content.default_model,
      &block
    )
      Releaf::Content::Route.for(node_class, node_content_class, controller).each do |route|
        Releaf::Content::RouterProxy.new(self, route).draw(&block)
      end
    end

    def for_node_class( node_class )
      previous_node_class = self.default_node_class
      self.default_node_class = node_class
      yield if block_given?
      self.default_node_class = previous_node_class
    end

    # expects Releaf::Content.routing hash or a subset of it as an argument
    def node_routing( routing )
      routing.each_pair do | node_class_name, node_class_routing |
        constraints node_class_routing[:constraints] do
          for_node_class(node_class_name.constantize) do
            yield
          end
        end
      end
    end

  end
end
