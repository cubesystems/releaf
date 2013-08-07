module Releaf
  class RolesController < BaseController

    def resource_class
      Releaf::Role
    end

    def available_admin_controllers
      available_admin_controllers = {}
      Releaf.available_admin_controllers.each do |controller|
        available_admin_controllers[t(controller, scope: 'admin.menu_items')] = controller
      end

      return available_admin_controllers
    end

    def fields_to_display
      return %w[name default_controller] if params[:action] == 'index'
      return %w[name default_controller permissions]
    end

    protected

    def resource_params
      return [] unless %w[update create].include? params[:action]
      return %w[name default_controller permissions]
    end
  end
end
