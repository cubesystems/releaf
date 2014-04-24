$:.push File.expand_path("../lib", __FILE__)

require "releaf/version"

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
end
