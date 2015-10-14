module Releaf::Permissions::Roles
  class FormBuilder < Releaf::Builders::FormBuilder
    def render_default_controller
      controllers = {}
      Releaf.application.config.available_controllers.each do |controller|
        controllers[I18n.t(controller, scope: 'admin.controllers')] = controller
      end

      releaf_item_field(:default_controller, options: {select_options: controllers})
    end

    def render_permissions
      options = {
        items: permission_items,
        field: :permission,
      }
      releaf_associated_set_field(:permissions, options: {association: options})
    end

    def permission_items
      list = {}
      Releaf.application.config.available_controllers.each do|controller|
        list["controller.#{controller}"] = t(controller, scope: "admin.controllers")
      end
      list
    end
  end
end
