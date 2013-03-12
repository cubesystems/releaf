module Releaf
  class SessionsController < Devise::SessionsController
    layout "releaf/devise"

    def full_controller_name
      self.class.name.sub(/Controller$/, '').downcase
    end
  end
end
