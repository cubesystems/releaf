module Releaf::Permissions::Devise
  def self.draw_component_routes(router)
    router.devise_for(Releaf.application.config.permissions.devise_for, path: "", controllers: { sessions: "releaf/permissions/sessions" })
  end
end
