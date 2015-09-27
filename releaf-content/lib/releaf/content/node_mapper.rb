module Releaf::Content
  module NodeMapper
    def releaf_routes_for(node_class, controller: default_controller(node_class), &block)
      Releaf::Content::Route.for(node_class, controller).each do |route|
        Releaf::Content::RouterProxy.new(self, route).draw(&block)
      end
    end

    private

    def default_controller(node_class)
      if node_class.is_a? ActionController::Base
        node_class.name.underscore.sub(/controller$/, '')
      else
        node_class.name.pluralize.underscore
      end
    end
  end
end
