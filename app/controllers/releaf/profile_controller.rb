module Releaf
  class ProfileController < BaseController

    def resource_class
      Releaf::Admin
    end

    def update
      old_password = @resource.password
      super

      # reload resource as password has been changed
      if @resource.password != old_password
        sign_in(self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}"), :bypass => true)
      end
    end

    def fields_to_display
      fields = super - %w[
        authentication_token
        confirmation_sent_at
        confirmation_token
        confirmed_at
        current_sign_in_at
        current_sign_in_ip
        encrypted_password
        failed_attempts
        last_sign_in_at
        last_sign_in_ip
        locked_at
        remember_created_at
        reset_password_sent_at
        reset_password_token
        sign_in_count
        unconfirmed_email
        unlock_token
        role_id
      ]

      fields += ['password', 'password_confirmation']

      return fields
    end


    protected

    def setup
      @features = {
        :edit     => true
      }
      @resource = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")
    end

    def resource_params
      return [] unless %w[create update].include? params[:action]
      %w[name surname email password password_confirmation locale]
    end
  end
end
