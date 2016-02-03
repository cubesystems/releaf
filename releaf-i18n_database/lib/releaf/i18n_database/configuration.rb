module Releaf::I18nDatabase
  class Configuration
    include Virtus.model(strict: true)
    attribute :create_missing_translations, Boolean
  end
end
