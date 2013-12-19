module Releaf
  class RoutesReloader
    def initialize(app)
      @app = app
      self.class.routes_loaded
    end

    def call(env)
      self.class.reload_if_expired
      @app.call(env)
    end

    def self.routes_loaded
      @updated_at = Time.now
    end

    def self.reload_if_expired
      if !Releaf::Node.updated_at.blank? && @updated_at < Releaf::Node.updated_at
        Rails.application.reload_routes!
        routes_loaded
      end
    end
  end
end
