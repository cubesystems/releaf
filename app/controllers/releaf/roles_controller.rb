module Releaf
  class RolesController < BaseController

    def resource_class
      Releaf::Role
    end

    def available_admin_controllers
      available_admin_controllers = {}
      Releaf.available_admin_controllers.each do |controller|
        available_admin_controllers[t(controller, :scope => 'admin.menu_items')] = controller
      end

      return available_admin_controllers
    end

    def fields_to_display
      case params[:action].to_sym
      when :index
        %w[name default_controller]
      when :create, :edit, :new, :update, :show
        %w[name default_controller permissions]
      else
        []
      end
    end

    protected

    def resource_params
      return [] unless %w[update create].include? params[:action]
      fields = ['name', 'default_controller', 'permissions']
      return fields
    end


  end
end
