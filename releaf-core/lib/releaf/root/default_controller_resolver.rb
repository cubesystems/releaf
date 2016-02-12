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
      Rails.application.routes.routes.map{|route| route.defaults}.include?(controller: controller_name, action: "index")
    end

    def controllers
      Releaf.application.config.available_controllers
    end
  end
end
