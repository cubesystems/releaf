module Releaf::Content
  class RoutesReloader
    UPDATED_AT_KEY = 'releaf.content.routes_reloader.updated_at'

    def initialize(app)
      @app = app
      routes_loaded
    end

    def call(env)
      reload_if_needed
      @app.call(env)
    end

    def routes_loaded
      Thread.current[UPDATED_AT_KEY] = Time.now
    end

    def reload_if_needed
      return unless needs_reload?
      Rails.application.reload_routes!
      routes_loaded
    end

    def needs_reload?
      return false unless Thread.current[UPDATED_AT_KEY].present?
      Releaf::Content.models.any? do | node_class |
        node_class.updated_at.present? && routes_updated_at < node_class.updated_at
      end
    end

    def routes_updated_at
      Thread.current[UPDATED_AT_KEY]
    end

  end
end
