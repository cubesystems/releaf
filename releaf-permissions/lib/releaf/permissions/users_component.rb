module Releaf::Permissions::UsersComponent
  def self.draw_component_routes router
    router.namespace :releaf, path: nil do
      router.namespace :permissions, path: nil do
        router.releaf_resources :users
      end
    end
  end
end
