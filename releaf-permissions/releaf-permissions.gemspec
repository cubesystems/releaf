require File.expand_path("../releaf-core/lib/releaf/version.rb", __dir__)

Gem::Specification.new do |s|
  s.name        = "releaf-permissions"
  s.version     = Releaf::VERSION

  s.summary     = "Built-in admin and role support for releaf"
  s.description = "Admin/role subsystem for releaf"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'

  s.files             = `git ls-files`.split("\n")
  s.test_files = Dir["spec/**/*"]

  s.add_dependency    'releaf-core', Releaf::VERSION
  s.add_dependency 'devise', '>= 2.1.0'

  s.required_ruby_version = '>= 2.1.0'
end
