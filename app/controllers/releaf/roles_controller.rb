module Releaf
  class RolesController < BaseController

    def self.resource_class
      Releaf::Role
    end

    def available_controllers
      controller_list = {}
      Releaf.available_controllers.each do |controller|
        controller_list[t(controller, scope: 'admin.menu_items')] = controller
      end

      controller_list
    end

    def fields_to_display
      return %w[name default_controller] if params[:action] == 'index'
      return %w[name default_controller permissions]
    end

    protected

    def setup
      super
      @features[:edit_ajax_reload] = false
    end

    def resource_params
      return [] unless %w[update create].include? params[:action]
      return [:name, :default_controller, permissions: []]
    end
  end
end
