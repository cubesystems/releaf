module Releaf::Permissions
  class ProfileController < Releaf::BaseController
    def success_url
      url_for(action: :edit)
    end

    def update
      old_password = @resource.password
      super

      # reload resource as password has been changed
      if @resource.password != old_password
        sign_in(user, bypass: true)
      end
    end

    def self.resource_class
      Releaf.application.config.permissions.devise_model_class
    end

    def controller_breadcrumb; end

    def setup
      @features = {
        edit: true,
      }

      # use already loaded admin user instance
      @resource = user.becomes(resource_class)
    end

    def permitted_params
      %w[name surname email password password_confirmation locale]
    end
  end
end
