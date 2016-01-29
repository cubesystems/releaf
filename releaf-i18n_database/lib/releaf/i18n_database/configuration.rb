module Releaf::I18nDatabase
  class Configuration
    attr_accessor :create_missing_translations

    def self.component_configuration
      new
    end
  end
end
