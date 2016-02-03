module Releaf::Service
  extend ActiveSupport::Concern

  included do
    include Virtus.model(strict: true)

    def self.call(*args)
      new(*args).call
    end
  end
end
