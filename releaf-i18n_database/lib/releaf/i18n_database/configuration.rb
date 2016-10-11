module Releaf::I18nDatabase
  class Configuration
    include Virtus.model(strict: true)
    attribute :auto_creation, Boolean
    attribute :auto_creation_exception_patterns, Array
  end
end
