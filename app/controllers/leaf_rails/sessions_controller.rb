module LeafRails
  class SessionsController < Devise::SessionsController
    layout "leaf_rails/admin"
  end
end
