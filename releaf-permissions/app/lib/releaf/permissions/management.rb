module Releaf::Permissions
  class Management
    include ActiveModel::Model
    attr_accessor :controller

    def authorize_controller!(controller_name)
      allowed_controllers.include?(controller_name) || user.role.permissions.include?(controller_name)
    end

    def current_controller_name
      controller.class.name.gsub("Controller", "").underscore
    end

    def user
      controller.send("current_#{self.class.devise_admin_model_name}")
    end

    def allowed_controllers
      ['releaf/permissions/profile', 'releaf/home']
    end

    def authorize!
      authenticate_devise!
      authorize_controller!(current_controller_name)
    end

    def authorized?
      method_name = "#{self.class.devise_admin_model_name}_signed_in?"
      controller.send(method_name)
    end

    def authenticate_devise!
      method_name = "authenticate_#{self.class.devise_admin_model_name}!"
      controller.send(method_name)
    end

    def self.devise_admin_model_name
      Releaf.devise_for.underscore.tr('/', '_')
    end
  end
end
