module Releaf
  class AdminsController < BaseController

    def current_object_class
      Releaf::Admin
    end

    def columns( view = nil )
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
      ]

      if view == 'index'
        fields -= ['avatar_uid']
      end

      if %w[new create edit update].include? view
        fields += ['password', 'password_confirmation']
      end

      return fields
    end

    protected

    def admin_params( action )
      return [] unless [:create, :update].include? action
      %w[name surname role_id email password password_confirmation phone avatar retained_avatar]
    end

  end
end
