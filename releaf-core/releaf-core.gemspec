require File.expand_path("../../lib/releaf/version.rb", __FILE__)

Gem::Specification.new do |s|
  s.name        = "releaf-core"
  s.version     = Releaf::VERSION

  s.summary     = "core gem for releaf"
  s.description = "Admin interface for RubyOnRails projects inspired by Leaf CMS"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'
  s.license     = "MIT"

  s.files       = Dir["app/**/*"] + Dir["lib/**/*"] + ["LICENSE"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'i18n', '~> 0.7'
  s.add_dependency 'sprockets-rails', '~> 3.0'
  s.add_dependency 'sass-rails', '~> 5.0'
  s.add_dependency 'jquery-rails', '~> 4.2'
  s.add_dependency 'jquery-ui-rails', '~> 5.0'
  s.add_dependency 'vanilla-ujs', '~> 1.2'
  s.add_dependency 'railties', '~> 4.2'
  s.add_dependency 'haml-rails', '~> 0.9'
  s.add_dependency 'dragonfly', '~> 1.0'
  s.add_dependency 'rails-settings-cached', '~> 0.4'
  s.add_dependency 'ckeditor_rails', '~> 4.5'
  s.add_dependency 'acts_as_list', '~> 0.8'
  s.add_dependency 'will_paginate', '~> 3.1'
  s.add_dependency 'font-awesome-rails', '~> 4.6'
  s.add_dependency 'globalize-accessors', '~> 0.2'
  s.add_dependency 'rack-cache', '~> 1.0'
  s.add_dependency 'virtus', '~> 1.0'
end
