module Releaf
  class HomeController < BaseController
    def index
      @user = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")
      unless @user.nil?
        respond_to do |format|
          format.html { redirect_to default_or_available_controller_path }
        end
      end
    end

    def page_not_found
      error_response('page_not_found', 404)
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
      return root_path
    end

    def controllers_to_try
      [@user.role.default_controller, @user.role.permissions].flatten.uniq
    end
  end
end
