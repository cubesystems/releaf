module Releaf
  class SessionsController < Devise::SessionsController
    layout "releaf/admin"
  end

  protected

  def after_sign_in_path_for resource
    releaf_root_path
  end

end
