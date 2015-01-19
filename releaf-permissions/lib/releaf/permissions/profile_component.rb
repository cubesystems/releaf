module Releaf::Permissions::ProfileComponent
  def self.draw_component_routes router
    router.namespace :releaf, path: nil do
      router.get "profile", to: "permissions/profile#edit", as: :permissions_user_profile
      router.patch "profile", to: "permissions/profile#update"
      router.post "profile/settings", to: "permissions/profile#settings", as: :permissions_user_profile_settings
    end
  end
end
