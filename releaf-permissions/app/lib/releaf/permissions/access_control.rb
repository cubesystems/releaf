module Releaf::Permissions
  class AccessControl
    include ActiveModel::Model
    attr_accessor :controller

    def controller_permitted?(controller_name)
      permitted_controllers.include?(controller_name) || user.role.controller_permitted?(controller_name)
    end

    def current_controller_name
      controller.class.name.gsub("Controller", "").underscore
    end

    def user
      controller.send("current_#{devise_model_name}")
    end

    def permitted_controllers
      ['releaf/permissions/home', 'releaf/core/errors']
    end

    def authorized?
      method_name = "#{devise_model_name}_signed_in?"
      controller.send(method_name)
    end

    def authenticate!
      method_name = "authenticate_#{devise_model_name}!"
      controller.send(method_name)
    end

    def devise_model_name
      Releaf.devise_for.underscore.tr('/', '_')
    end
  end
end
