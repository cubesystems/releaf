module Releaf::Content
  module NodeMapper
    def releaf_routes_for(node_class, controller: Releaf::Content::Route.node_class_default_controller(node_class), &block)
      Releaf::Content::Route.for(node_class, controller).each do |route|
        Releaf::Content::RouterProxy.new(self, route).draw(&block)
      end
    end
  end
end
