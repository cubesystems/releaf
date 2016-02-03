module Releaf::Permissions
  class SettingsManager
    def self.configure_component
      Releaf.application.config.settings_manager = self
    end

    def self.read(controller:, key:)
      controller.user.settings[key] if controller.respond_to? :user
    end

    def self.write(controller:, key:, value:)
      # Sometimes concurrency happens, so lets try until
      # record get updated
      begin
        controller.user.settings[key] = value
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
  end
end

