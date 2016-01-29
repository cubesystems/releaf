module Releaf::Core::Root
  extend Releaf::Core::Component

  def self.component_configuration
    Releaf::Core::Root::Configuration.new
  end

  def self.initialize_component
    Releaf.application.config.root.default_controller_resolver = Releaf::Core::Root::DefaultControllerResolver
    Releaf.application.config.settings_manager = Releaf::Core::Root::SettingsManager
  end

  def self.draw_component_routes(router)
    router.namespace :releaf, path: nil do
      router.root to: "core/root#home", as: :root
      router.post "store_settings", to: "core/root#store_settings"
    end
  end
end
