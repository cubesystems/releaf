require File.expand_path("../../lib/releaf/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = "releaf-i18n_database"
  s.version     = Releaf::VERSION

  s.summary     = "i18n database gem for releaf"
  s.description = "i18n database backend for releaf"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'
  s.license     = "MIT"

  s.files       = Dir["app/**/*"] + Dir["lib/**/*"] + Dir["misc/**/*"] + ["LICENSE"]

  s.add_dependency 'releaf-core', Releaf::VERSION
  s.add_dependency 'rails-i18n'
  s.add_dependency 'caxlsx_rails', '~> 0.6'
  s.add_dependency 'roo'
end
