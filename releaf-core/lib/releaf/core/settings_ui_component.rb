module Releaf::Core::SettingsUIComponent
  extend Releaf::Core::Component

  def self.draw_component_routes router
    resource_route(router, :core, :settings)
  end
end
