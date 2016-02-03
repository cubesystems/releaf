module Releaf::Root
  extend Releaf::Component

  def self.configure_component
    Releaf.application.config.add_configuration(
      Releaf::Root::Configuration.new(default_controller_resolver: Releaf::Root::DefaultControllerResolver)
    )
    Releaf.application.config.settings_manager = Releaf::Root::SettingsManager
  end

  def self.draw_component_routes(router)
    router.namespace :releaf, path: nil do
      router.root to: "root#home", as: :root
      router.post "store_settings", to: "root#store_settings"
    end
  end
end
