module Releaf
  class HomeController < BaseController
    def index
      user = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")
      unless user.nil?
        respond_to do |format|
          format.html { redirect_to url_for(action: 'index', controller: '/' + user.role.default_controller) }
        end
      end
    end

    def page_not_found
      error_response('page_not_found', 404)
    end
  end
end
