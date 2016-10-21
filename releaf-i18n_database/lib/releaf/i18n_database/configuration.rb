module Releaf::I18nDatabase
  class Configuration
    include Virtus.model(strict: true)
    attribute :translation_auto_creation, Boolean
    attribute :translation_auto_creation_patterns, Array
    attribute :translation_auto_creation_exclusion_patterns, Array
  end
end
