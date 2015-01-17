module Releaf::Permissions::RolesComponent
  def self.draw_component_routes router
    router.namespace :releaf, path: nil do
      router.namespace :permissions, path: nil do
        router.releaf_resources :roles
      end
    end
  end
end
