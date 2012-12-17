module LeafRails
  class SessionsController < Devise::SessionsController
    layout "leaf_rails/admin"

    def new
      # redirect_to "/status/"
      super
      # render :layout => 'admin'
    end
  end
end
