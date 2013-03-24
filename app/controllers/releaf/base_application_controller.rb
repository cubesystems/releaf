module Releaf
  class BaseApplicationController < ActionController::Base

    before_filter "authenticate_#{ReleafDeviseHelper.devise_admin_model_name}!"
    # check_authorization :unless => :devise_controller?
    layout Releaf.layout
    protect_from_forgery

    def full_controller_name
      self.class.name.sub(/Controller$/, '').underscore
    end

  end
end
