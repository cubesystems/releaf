module Releaf::SettingsUI
  extend Releaf::Component

  def self.draw_component_routes router
    resource_route(router, nil, :settings)
  end
end
