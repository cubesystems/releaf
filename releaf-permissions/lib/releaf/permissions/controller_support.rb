module Releaf::Permissions
  module ControllerSupport
    extend ActiveSupport::Concern

    included do
      prepend_before_action :set_locale, :verify_controller_access!, :authenticate!
    end

    def set_locale
      I18n.locale = user.locale
    end

    def verify_controller_access!
      unless Releaf.application.config.permissions.access_control.new(user: user).controller_permitted?(short_name)
        raise Releaf::AccessDenied
      end
    end

    def user
      send("current_#{Releaf.application.config.permissions.devise_model_name}")
    end

    def authorized?
      method_name = "#{Releaf.application.config.permissions.devise_model_name}_signed_in?"
      send(method_name)
    end

    def authenticate!
      method_name = "authenticate_#{Releaf.application.config.permissions.devise_model_name}!"
      send(method_name)
    end
  end
end
