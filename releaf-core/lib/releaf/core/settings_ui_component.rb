module Releaf::Core::SettingsUIComponent
  def self.draw_component_routes router
    router.namespace :releaf, path: nil do
      router.namespace :core, path: nil do
        router.releaf_resources :settings
      end
    end
  end
end
