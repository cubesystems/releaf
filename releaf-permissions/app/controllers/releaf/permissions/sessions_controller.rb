class Releaf::Permissions::SessionsController < Devise::SessionsController
  include Releaf::ActionController::Layout
  layout "releaf/admin"
  helper_method :page_title

  def page_title
    Rails.application.class.parent_name
  end

  protected

  def after_sign_in_path_for(resource)
    if custom_redirect_path
      custom_redirect_path
    else
      stored_location_for(resource) || releaf_root_path
    end
  end

  def custom_redirect_path
    return nil if params[:redirect_to].blank?
    return nil if params[:redirect_to][0] != '/'
    return params[:redirect_to]
  end
end
