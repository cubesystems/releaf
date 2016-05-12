module Releaf::Root
  class DefaultControllerResolver
    include Releaf::Service
    attribute :current_controller

    def call
      controllers.each do |controller_name|
        path = controller_index_path(controller_name)
        return path if path
      end

      nil
    end

    def controller_index_path(controller_name)
      route_options = {controller: controller_name, action: "index"}

      subdomain.present? && route_path(route_options.merge(subdomain: subdomain)) || route_path(route_options)
    end

    def route_path(route_options)
      Rails.application.routes.url_helpers.url_for(route_options.merge(only_path: true)) if route_exists?(route_options)
    end

    def controllers
      Releaf.application.config.available_controllers
    end

    def route_exists?(route_options)
      Rails.application.routes.routes.map(&:defaults).include?(route_options)
    end

    def subdomain
      current_controller.request.subdomain
    end
  end
end
