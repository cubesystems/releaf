$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "leaf_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "leaf_rails"
  s.version     = LeafRails::VERSION


  s.date        = '2012-12-21'
  s.summary     = "Admin interface for RubyOnRails projects"
  s.description = "Admin interface for RubyOnRails projects inspired by Leaf CMS"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://git.cubesystems.lv/leaf_rails'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "sass-rails", "~> 3.2.5"
  s.add_dependency "jquery-rails"

  # s.add_development_dependency "sqlite3"

  s.add_dependency("railties", "~> 3.1")
  s.add_dependency("haml-rails", "~> 0.3.4")
  s.add_dependency('dragonfly', '~>0.9.12')
  s.add_dependency('devise', '~> 2.1.2')
  s.add_dependency('cancan', '~> 1.6.8')
  s.add_dependency('yui-rails', '~> 0.1.0')
end
