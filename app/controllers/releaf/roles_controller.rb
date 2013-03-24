module Releaf
  class RolesController < BaseController

    def resource_class
      Releaf::Role
    end

    def fields_to_display
      case params[:action].to_sym
      when :index
        %w[name default_controller default]
      when :create, :edit, :new, :update, :show
        %w[name default default_controller permissions]
      else
        []
      end
    end

    protected

    def resource_params
      return [] unless %w[update create].include? params[:action]

      fields = ['name', 'default', 'default_controller']

      Releaf.available_admin_controllers.each do |controller_name|
        permission = controller_name.gsub("/", "_")
        fields.push "#{permission}_permission"
      end

      return fields
    end

  end
end
