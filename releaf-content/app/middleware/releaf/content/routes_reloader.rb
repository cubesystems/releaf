module Releaf::Content
  class RoutesReloader
    def initialize(app)
      @app = app
      routes_loaded
    end

    def call(env)
      reload_if_needed
      @app.call(env)
    end

    def routes_loaded
      @updated_at = Time.now
    end

    def reload_if_needed
      return unless needs_reload?
      Rails.application.reload_routes!
      routes_loaded
    end

    def needs_reload?
      return false unless @updated_at.present?
      Releaf::Content.models.any? do | node_class |
        node_class.updated_at.present? && @updated_at < node_class.updated_at
      end
    end

  end
end
