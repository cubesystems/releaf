require 'dragonfly/rails/images'
if Rails.env.test?
  Rails.application.middleware.delete Rack::Cache
  Rails.application.middleware.insert 0, Rack::Cache, {
    :verbose     => false,
    :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
    :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
  }
end
