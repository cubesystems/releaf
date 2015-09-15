require File.expand_path("../../releaf-core/lib/releaf/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = "releaf-content"
  s.version     = Releaf::VERSION

  s.summary     = "Node and content routes support for releaf"
  s.description = "Content subsystem for releaf"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'

  s.files             = `git ls-files`.split("\n")
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'releaf-core', Releaf::VERSION
  s.add_dependency 'stringex'
  s.add_dependency 'awesome_nested_set'

  s.required_ruby_version = '>= 2.2.0'
end
