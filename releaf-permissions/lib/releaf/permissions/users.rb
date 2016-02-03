module Releaf::Permissions::Users
  extend Releaf::Component

  def self.configure_component
    Releaf.application.config.permissions.devise_for = 'releaf/permissions/user'
  end

  def self.draw_component_routes(router)
    resource_route(router, :permissions, :users)
  end
end
