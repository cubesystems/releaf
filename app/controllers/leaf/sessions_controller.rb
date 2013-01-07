module Leaf
  class SessionsController < Devise::SessionsController
    layout "leaf/admin"
  end
end
