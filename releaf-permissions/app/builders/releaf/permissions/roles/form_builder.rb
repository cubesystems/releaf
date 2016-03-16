module Releaf::Permissions::Roles
  class FormBuilder < Releaf::Builders::FormBuilder
    def render_default_controller
      controllers = {}
      Releaf.application.config.available_controllers.each do |controller_name|
        definition = controller_definition(controller_name)
        controllers[definition.localized_name] = definition.controller_name
      end

      releaf_item_field(:default_controller, options: {select_options: controllers})
    end

    def controller_definition(controller_name)
      Releaf::ControllerDefinition.for(controller_name)
    end

    def render_permissions
      options = {
        items: permission_items,
        field: :permission,
      }
      releaf_associated_set_field(:permissions, options: {association: options})
    end

    def permission_items
      Releaf.application.config.available_controllers.inject({}) do |h, controller_name|
        definition = controller_definition(controller_name)
        h.update("controller.#{definition.controller_name}" => definition.localized_name)
      end
    end
  end
end
