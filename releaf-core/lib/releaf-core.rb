module Releaf
  require 'releaf/core/engine'
  require 'releaf/core/configuration'
  require 'releaf/core/application'
  require 'releaf/core/route_mapper'
  require 'releaf/core/exceptions'
  require 'releaf/core/validation_error_codes'

  class << self
    def application
      @@application ||= Releaf::Core::Application.new
    end
  end
end
