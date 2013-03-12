module Releaf
  class SessionsController < Devise::SessionsController
    layout "releaf/devise"

    def full_controller_name
      self.class.name.sub(/Controller$/, '').underscore
    end
  end
end
