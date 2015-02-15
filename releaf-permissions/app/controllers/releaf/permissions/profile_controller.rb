module Releaf::Permissions
  class ProfileController < Releaf::BaseController
    # Store settings for menu collapsing and others
    def settings
      if params[:settings].is_a? Hash
        params[:settings].each_pair do|key, value|
          value = false if value == "false"
          value = true if value == "true"
          # Sometimes concurrency happens, so lets try until
          # record get updated
          begin
            @resource.settings[key] = value
          rescue ActiveRecord::RecordNotUnique
            retry
          end
        end
        render nothing: true, status: 200
      else
        render nothing: true, status: 422
      end
    end

    def success_url
      url_for(action: :edit)
    end

    def update
      old_password = @resource.password
      super

      # reload resource as password has been changed
      if @resource.password != old_password
        sign_in(access_control.user, bypass: true)
      end
    end

    def self.resource_class
      Releaf.devise_for.classify.constantize
    end

    def controller_breadcrumb; end

    def setup
      @features = {
        edit: true,
      }

      # use already loaded admin user instance
      @resource = access_control.user
    end

    def permitted_params
      %w[name surname email password password_confirmation locale]
    end
  end
end
