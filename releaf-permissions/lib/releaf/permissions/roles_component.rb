module Releaf::Permissions::RolesComponent
  extend Releaf::Core::Component

  def self.draw_component_routes router
    resource_route(router, :permissions, :roles)
  end
end
