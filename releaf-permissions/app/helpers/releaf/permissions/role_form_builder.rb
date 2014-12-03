module Releaf::Permissions
  class RoleFormBuilder < Releaf::FormBuilder
    def field_names
      %w[name default_controller permissions]
    end

    def render_default_controller
      controllers = {}
      Releaf.available_controllers.each do |controller|
        controllers[I18n.t(controller, scope: 'admin.menu_items')] = controller
      end

      releaf_item_field(:default_controller, options: {select_options: controllers})
    end

    def render_permissions
      releaf_checkbox_group(:permissions, options: {items: permissions_items})
    end

    def permissions_items
      Releaf.available_controllers.collect do |controller_name|
        {value: controller_name, label: t(controller_name, scope: "admin.menu_items")}
      end
    end
  end
end
