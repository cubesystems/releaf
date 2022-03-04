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

  s.add_dependency 'rails', '~> 6.1'
  s.add_dependency 'activesupport', '~> 6.1'
  s.add_dependency 'activerecord', '~> 6.1'
  s.add_dependency 'i18n', '~> 1.8'
  s.add_dependency 'sprockets-rails', '~> 3.0'
  s.add_dependency 'sass-rails', '~> 6.0'
  s.add_dependency 'jquery-rails', '~> 4.4'
  s.add_dependency 'jquery-ui-rails', '~> 6.0'
  s.add_dependency 'vanilla-ujs', '~> 1.3'
  s.add_dependency 'railties', '~> 6.0'
  s.add_dependency 'haml-rails', '~> 2.0'
  s.add_dependency 'bootsnap', '~> 1.4'
  s.add_dependency 'net-smtp', '~> 0.3'
  s.add_dependency 'dragonfly', '~> 1.0'
  s.add_dependency 'ckeditor_rails', '~> 4.0'
  s.add_dependency 'acts_as_list', '~> 0.8'
  s.add_dependency 'will_paginate', '~> 3.1'
  s.add_dependency 'font-awesome-rails', '~> 4.0'
  s.add_dependency 'globalize', '~> 6.0'
  s.add_dependency 'rack-cache', '~> 1.0'
  s.add_dependency 'virtus', '~> 1.0'
end
