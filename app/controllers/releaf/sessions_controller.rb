module Releaf
  class SessionsController < Devise::SessionsController
    layout "releaf/devise"

    def after_sign_in_path_for(resource)
      controller_name = resource.role.default_controller
      controller = Releaf.controller_list[controller_name]

      if controller.has_key? :helper 
        url = send(controller[:helper] + "_path")
      else
        url = send(controller[:controller].gsub('/', '_') + "_path")
      end

      return url
    end

  end
end
