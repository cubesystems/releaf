module Releaf
  class BaseApplicationController < ActionController::Base

    before_filter "authenticate_#{ReleafDeviseHelper.devise_admin_model_name}!"
    # check_authorization :unless => :devise_controller?
    layout Releaf.layout
    protect_from_forgery

    def current_ability
      @current_ability ||= AdminAbility.new(self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}"))
    end

  end
end
