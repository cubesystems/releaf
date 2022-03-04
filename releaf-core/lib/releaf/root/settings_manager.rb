module Releaf::Root
  class SettingsManager
    CAST_MAP = {
      "false" => false,
      "true" => true,
    }

    def self.read(controller:, key:)
      value = controller.send(:cookies)[key]

      return CAST_MAP[value] if CAST_MAP.key? value

      value
    end

    def self.write(controller:, key:, value:)
      controller.send(:cookies)[key] = value
    end
  end
end
