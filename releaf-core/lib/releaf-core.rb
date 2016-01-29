require 'releaf/core/engine'

module Releaf
  class << self
    def application
      @@application ||= Releaf::Core::Application.new
    end
  end
end
