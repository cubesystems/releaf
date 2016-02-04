module Releaf::Root
  class DefaultControllerResolver
    include Releaf::Service
    attribute :current_controller

    def call
      controllers.each do |controller_name|
        path = controller_index_path(controller_name)
        return path if path.present?
      end
    end

    def controller_index_path(controller_name)
      begin
        Rails.application.routes.url_helpers.url_for(action: "index", controller: controller_name, only_path: true)
      rescue ActionController::UrlGenerationError
      end
    end

    def controllers
      Releaf.application.config.available_controllers
    end
  end
end
