module Releaf::Permissions
  class HomeController < Releaf::BaseController
    def home
      respond_to do |format|
        format.html { redirect_to default_or_available_controller_path }
      end
    end
    protected

    def default_or_available_controller_path
      controllers_to_try.each do |controller_string|
        begin
          return url_for(action: 'index', controller: "/#{controller_string}")
        rescue ActionController::UrlGenerationError
          next
        end
      end

      root_path
    end

    def controllers_to_try
      [access_control.user.role.default_controller, allowed_controllers].flatten.uniq
    end

    def allowed_controllers
      # Note: This basically sorts allowed controllers in order specified by
      # Releaf.available_controllers
      Releaf.available_controllers & access_control.user.role.allowed_controllers
    end
  end
end
