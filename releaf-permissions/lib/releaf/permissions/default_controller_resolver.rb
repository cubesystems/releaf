module Releaf::Permissions
  class DefaultControllerResolver < Releaf::Root::DefaultControllerResolver

    def self.configure_component
      Releaf.application.config.root.default_controller_resolver = self
    end

    def controllers
      # Note: This basically sorts allowed controllers in order specified by
      # Releaf.application.config.available_controllers
      ([user.role.default_controller] + super).uniq & allowed_controllers
    end

    def allowed_controllers
      Releaf.application.config.permissions.access_control.new(user: user).allowed_controllers
    end

    def user
      current_controller.user
    end
  end
end
