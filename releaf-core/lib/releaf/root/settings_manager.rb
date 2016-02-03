module Releaf::Root
  class SettingsManager

    def self.read(controller:, key:)
      controller.send(:cookies)[key]
    end

    def self.write(controller:, key:, value:)
      controller.send(:cookies)[key] = value
    end
  end
end
