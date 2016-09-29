module Releaf::Content
  class RoutesReloader
    def initialize(app)
      @app = app
      self.class.routes_loaded
    end

    def call(env)
      self.class.reload_if_needed
      @app.call(env)
    end

    def self.reset!
      @updated_at = nil
    end

    def self.routes_loaded
      @updated_at = Time.now
    end

    def self.reload_if_needed
      return unless needs_reload?
      Rails.application.reload_routes!
      routes_loaded
    end

    def self.needs_reload?
      Releaf::Content.models.any? do | node_class |
        node_class.updated_at.present? && (@updated_at.nil? || @updated_at < node_class.updated_at)
      end
    end
  end
end
