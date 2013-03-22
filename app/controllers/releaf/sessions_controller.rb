module Releaf
  class SessionsController < Devise::SessionsController
    layout "releaf/devise"

    def after_sign_in_path_for(resource)
      controller_name = resource.role.default_controller

      if controller_name
        if controller_name == 'content'
          default_path = releaf_nodes_path
        elsif controller_name == 'translations'
          default_path = releaf_translation_groups_path
        else
          default_path = send("admin_#{controller_name}_path")
        end
      else
        default_path = releaf_nodes_path
      end

      return default_path
    end

    def full_controller_name
      self.class.name.sub(/Controller$/, '').underscore
    end
  end
end
