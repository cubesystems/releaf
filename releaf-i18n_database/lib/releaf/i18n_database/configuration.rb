module Releaf::I18nDatabase
  class Configuration
    include Virtus.model(strict: true)
    attribute :create_missing_translations, Boolean
    attribute :auto_creation_exception_patterns, Array
  end
end
