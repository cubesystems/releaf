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
      [access_control.user.role.default_controller, access_control.user.role.allowed_controllers].flatten.uniq
    end
  end
end
