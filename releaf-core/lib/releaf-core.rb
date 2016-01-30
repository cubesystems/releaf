module Releaf
  require 'releaf/core/engine'

  class << self
    def application
      @@application ||= Releaf::Core::Application.new
    end
  end
end
