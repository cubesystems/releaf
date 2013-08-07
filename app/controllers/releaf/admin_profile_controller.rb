module Releaf
  class AdminProfileController < BaseController

    def update
      old_password = @resource.password
      super

      # reload resource as password has been changed
      if @resource.password != old_password
        sign_in(self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}"), bypass: true)
      end
    end

    def fields_to_display
      return %w[
        name
        surname
        locale
        email
        password
        password_confirmation
      ]
    end

    protected

    def setup
      @features = {
        edit: true
      }

      # use already loaded admin user instance
      @resource = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")
    end

    def resource_params
      return [] unless %w[create update].include? params[:action]
      %w[name surname email password password_confirmation locale]
    end
  end
end
