module Releaf::Core::Root
  extend Releaf::Core::Component

  def self.configure_component
    Releaf.application.config.add_configuration(
      Releaf::Core::Root::Configuration.new(default_controller_resolver: Releaf::Core::Root::DefaultControllerResolver)
    )
    Releaf.application.config.settings_manager = Releaf::Core::Root::SettingsManager
  end

  def self.draw_component_routes(router)
    router.namespace :releaf, path: nil do
      router.root to: "core/root#home", as: :root
      router.post "store_settings", to: "core/root#store_settings"
    end
  end
end
