module Releaf::Permissions
  class AccessControl
    include Virtus.model(strict: true)
    attribute :user, Object

    def self.initialize_component
      ActiveSupport.on_load :base_controller do
        Releaf::ActionController.send(:include, Releaf::Permissions::ControllerSupport)
      end
    end

    def self.draw_component_routes(router)
      router.devise_for(Releaf.application.config.permissions.devise_for, path: "", controllers: { sessions: "releaf/permissions/sessions" })
    end

    def controller_permitted?(controller_name)
      allowed_controllers.include?(controller_name)
    end

    def allowed_controllers
      permanent_allowed_controllers + role_allowed_controllers
    end

    def role_allowed_controllers
      user.role.permissions.map{|permission| controller_name_from_permission(permission.permission) }.compact
    end

    def controller_name_from_permission(permission)
      match = permission.match(/^controller\.(.+)/)
      match[1] if match
    end

    def permanent_allowed_controllers
      Releaf.application.config.permissions.permanent_allowed_controllers
    end
  end
end
