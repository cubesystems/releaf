module Releaf
  class AdminProfileController < BaseController

    def settings
      if params[:settings].is_a? Hash
        params[:settings].each_pair do|key, value|
          value = false if value == "false"
          value = true if value == "true"
          @resource.settings[key] = value
        end
        render nothing: true, status: 200
      else
        render nothing: true, status: 422
      end
    end

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
