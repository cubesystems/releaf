require File.expand_path("../releaf-core/lib/releaf/version.rb", __dir__)

Gem::Specification.new do |s|
  s.name        = "releaf-i18n"
  s.version     = Releaf::VERSION

  s.summary     = "i18n gem for releaf"
  s.description = "Database i18n backend for releaf"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'

  s.files             = `git ls-files`.split("\n")
  s.test_files = Dir["spec/**/*"]

  s.required_ruby_version = '>= 2.1.0'
end
