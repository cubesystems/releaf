module Releaf::Core::SettingsComponent
  def self.draw_component_routes router
    router.namespace :core, path: nil do
      router.releaf_resources :settings
    end
  end
end
