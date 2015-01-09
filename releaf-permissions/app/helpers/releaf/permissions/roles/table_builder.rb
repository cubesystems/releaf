module Releaf::Permissions::Roles
  class TableBuilder < Releaf::Builders::TableBuilder
    def column_names
      [:name, :default_controller]
    end

    def default_controller_content(resource)
      value = resource.default_controller
      if value.nil?
        '-'
      else
        I18n.t(value.sub('_', '/'), scope: 'admin.menu_items')
      end
    end
  end
end
