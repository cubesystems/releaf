module Releaf
  class SessionsController < Devise::SessionsController
    layout "releaf/admin"
  end
end
