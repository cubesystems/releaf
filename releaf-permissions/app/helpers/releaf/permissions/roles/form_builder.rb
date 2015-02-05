module Releaf::Permissions::Roles
  class FormBuilder < Releaf::Builders::FormBuilder
    def render_default_controller
      controllers = {}
      Releaf.available_controllers.each do |controller|
        controllers[I18n.t(controller, scope: 'admin.menu_items')] = controller
      end

      releaf_item_field(:default_controller, options: {select_options: controllers})
    end

    def render_permissions
      options = {
        values: Releaf.available_controllers,
        field: :permission,
        translation_scope: "admin.menu_items"
      }
      releaf_associated_set_field(:permissions, options: {association: options})
    end
  end
end
