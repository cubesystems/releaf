module Releaf::Root
  class Configuration
    include Virtus.model(strict: true)
    attribute :default_controller_resolver, Class
  end
end
