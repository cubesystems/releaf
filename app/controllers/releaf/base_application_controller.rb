module Releaf
  class BaseApplicationController < ActionController::Base

    before_filter "authenticate_#{ReleafDeviseHelper.devise_admin_model_name}!"
    before_filter :set_locale

    rescue_from Releaf::AccessDenied, :with => :access_denied

    # check_authorization :unless => :devise_controller?
    layout Releaf.layout
    protect_from_forgery

    def full_controller_name
      self.class.name.sub(/Controller$/, '').underscore
    end

    def set_locale
      admin = send("current_" + ReleafDeviseHelper.devise_admin_model_name)
      I18n.locale = admin.locale
      Releaf::Globalize3::Fallbacks.set
    end

    def access_denied
      @controller_name = full_controller_name
      render :template => 'error_pages/access_denied'
    end
  end
end
