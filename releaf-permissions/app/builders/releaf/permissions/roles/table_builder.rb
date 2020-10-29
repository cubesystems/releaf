module Releaf::Permissions::Roles
  class TableBuilder < Releaf::Builders::TableBuilder
    def column_names
      [:name, :default_controller]
    end

    def default_controller_content(resource)
      definition = resource.default_controller ? Releaf::ControllerDefinition.for(resource.default_controller) : nil
      definition ? definition.localized_name : "-"
    end
  end
end
