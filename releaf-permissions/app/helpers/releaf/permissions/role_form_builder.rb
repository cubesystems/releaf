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
      releaf_check_boxes(:permissions, options: {check_boxes_options: permissions_options})
    end

    def permissions_options
      Releaf.available_controllers.collect do |controller_name|
        {
          checked: object.permissions.include?(controller_name),
          value: controller_name,
          label: I18n.t(controller_name, scope: "admin.menu_items")
        }
      end
    end
  end
end
