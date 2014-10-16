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
      safe_join do
        Releaf.available_controllers.collect do |controller_name|
          permission_field(controller_name)
        end
      end
    end

    def permission_field(controller_name)
      field = field_attributes(controller_name, {}, {field: {type: "boolean"}})
      checked = object.permissions.include?(controller_name)
      normalized_name = controller_name.gsub('/', '_')

      wrapper(field) do
        wrapper(class: "value") do
          template.check_box_tag("resource[permissions][]", controller_name, checked, id: normalized_name) <<
            template.label_tag(normalized_name, I18n.t(controller_name, scope: "admin.menu_items"))
        end
      end
    end
  end
end
