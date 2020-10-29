module Releaf::Root
  class DefaultControllerResolver
    include Releaf::Service
    attribute :current_controller

    def call
      Releaf.application.config.controllers[controllers.first].path if controllers.first
    end

    def controllers
      Releaf.application.config.available_controllers
    end
  end
end
