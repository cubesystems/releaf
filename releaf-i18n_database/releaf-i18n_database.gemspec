require File.expand_path("../../releaf-core/lib/releaf/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = "releaf-i18n_database"
  s.version     = Releaf::VERSION

  s.summary     = "i18n database gem for releaf"
  s.description = "i18n database backend for releaf"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'

  s.files             = `git ls-files`.split("\n")
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'releaf-core', Releaf::VERSION
  s.add_dependency 'twitter_cldr'

  s.required_ruby_version = '>= 2.1.0'
end
