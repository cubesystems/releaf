module Releaf::I18nDatabase
  class CacheReloader
    def initialize(app)
      @app = app
    end

    def call(env)
      reload_if_expired unless asset_request?(env)
      @app.call(env)
    end

    def asset_request?(env)
      env['PATH_INFO'].start_with?(asset_prefix)
    end

    def asset_prefix
      @asset_prefix ||= Rails.configuration.assets[:prefix] + '/'
    end

    def reload_if_expired
      backend.reload_cache if backend.cache_expired?
    end

    def backend
      I18n.backend
    end
  end
end
