module Releaf::Permissions::Users
  extend Releaf::Core::Component

  def self.draw_component_routes(router)
    resource_route(router, :permissions, :users)
  end
end
