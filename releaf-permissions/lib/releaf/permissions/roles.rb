module Releaf::Permissions::Roles
  extend Releaf::Component

  def self.draw_component_routes router
    resource_route(router, :permissions, :roles)
  end
end
