class Admin::AdminsController < Admin::BaseController
  def columns( view = nil )
    super() - ['encrypted_password']
  end

end
