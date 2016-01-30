module Releaf::Permissions::Profile

  def self.configure_component
    Releaf.application.config.additional_controllers = Releaf.application.config.additional_controllers + ['releaf/permissions/profile']
  end

  def self.draw_component_routes router
    router.namespace :releaf, path: nil do
      router.get "profile", to: "permissions/profile#edit", as: :permissions_user_profile
      router.patch "profile", to: "permissions/profile#update"
    end
  end
end
