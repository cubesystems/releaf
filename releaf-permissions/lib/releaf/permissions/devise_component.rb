module Releaf::Permissions::DeviseComponent
  def self.draw_component_routes router
    router.devise_for Releaf.devise_for, path: "", controllers: { sessions: "releaf/permissions/sessions" }
  end
end
