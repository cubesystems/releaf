module Releaf::Root
  class DefaultControllerResolver
    include Releaf::Service
    attribute :current_controller

    def call
      controllers.each do |controller_name|
        return controller_index_path(controller_name) if controller_index_exists?(controller_name)
      end
    end

    def controller_index_path(controller_name)
      Rails.application.routes.url_helpers.url_for(action: "index", controller: controller_name, only_path: true)
    end

    def controller_index_exists?(controller_name)
      route_options = { controller: controller_name, action: "index" }
      if subdomain.present?
        # If subdomain is present try to find route matching it
        # since it'll be most specific route
        subdomain_route_options = route_options.merge(subdomain: subdomain)
        return true if route_defaults.include?(subdomain_route_options)
      end
      route_defaults.include?(route_options)
    end

    def controllers
      Releaf.application.config.available_controllers
    end

    private

    def route_defaults
      @route_defaults ||= Rails.application.routes.routes.map(&:defaults)
    end

    def subdomain
      current_controller.request.subdomain
    end
  end
end
