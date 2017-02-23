require File.expand_path("../../lib/releaf/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = "releaf-content"
  s.version     = Releaf::VERSION

  s.summary     = "Node and content routes support for releaf"
  s.description = "Content subsystem for releaf"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'
  s.license     = "MIT"

  s.files       = Dir["app/**/*"] + Dir["lib/**/*"] + ["LICENSE"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency 'releaf-core', Releaf::VERSION
  s.add_dependency 'stringex', '~> 2.6'
  s.add_dependency 'awesome_nested_set', '~> 3.1'
  s.add_dependency 'deep_cloneable', '~> 2.2.2'
end
