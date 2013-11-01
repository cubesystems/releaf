module Releaf
  class SessionsController < Devise::SessionsController
    layout "releaf/admin"

    helper_method :page_title

    def page_title
      Rails.application.class.parent_name
    end

    protected

    def after_sign_in_path_for resource
      releaf_root_path
    end
  end
end
