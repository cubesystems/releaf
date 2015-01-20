module Releaf::Permissions::DeviseComponent
  def self.draw_component_routes router
    router.devise_for Releaf.devise_for, path: "", controllers: { sessions: "releaf/permissions/sessions" }
    router.namespace :releaf, path: nil do
      router.root to: "permissions/home#home", as: :root
    end
  end
end
