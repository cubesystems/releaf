module Releaf
  class BaseApplicationController < ActionController::Base
    helper_method \
      :current_feature

    before_filter "authenticate_#{ReleafDeviseHelper.devise_admin_model_name}!"
    before_filter :set_locale

    rescue_from Releaf::AccessDenied,           :with => :access_denied

    # check_authorization :unless => :devise_controller?
    layout Releaf.layout
    protect_from_forgery

    helper_method :controller_scope_name

    def full_controller_name
      self.class.name.sub(/Controller$/, '').underscore
    end

    def controller_scope_name
      'admin.' + self.class.name.sub(/Controller$/, '').underscore.gsub('/', '_')
    end

    def set_locale
      admin = send("current_" + ReleafDeviseHelper.devise_admin_model_name)
      I18n.locale = admin.locale
      Releaf::Globalize3::Fallbacks.set
    end

    def access_denied
      @controller_name = full_controller_name
      respond_to do |format|
        format.html { render :template => 'error_pages/access_denied', :status => 403 }
        format.any  { render :text => '', :status =>403 }
      end
    end

    def page_not_found
      respond_to do |format|
        format.html { render :template => 'error_pages/page_not_found', :status => 404 }
        format.any  { render :text => '', :status => 404 }
      end
    end

    # Helper that returns current feature
    def current_feature
      case params[:action].to_sym
      when :index
        return :index
      when :new, :create
        return :create
      when :edit, :update
        return :edit
      when :destroy, :confirm_destroy
        return :destroy
      else
        return params[:action].to_sym
      end
    end
  end
end
