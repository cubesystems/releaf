require File.expand_path('../lib/releaf/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "releaf-core"
  s.version     = Releaf::VERSION

  s.summary     = "core gem for releaf"
  s.description = "Admin interface for RubyOnRails projects inspired by Leaf CMS"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'

  s.files             = `git ls-files`.split("\n")
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '5.0.0.beta2'
  s.add_dependency 'i18n', '>= 0.7.0'
  s.add_dependency 'sprockets-rails', '>= 3.0.0'
  s.add_dependency 'sass-rails'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'railties'
  s.add_dependency 'haml-rails'
  s.add_dependency 'dragonfly'
  s.add_dependency 'rails-settings-cached', '>= 0.4.5'
  s.add_dependency 'ckeditor_rails'
  s.add_dependency 'acts_as_list'
  s.add_dependency 'will_paginate'
  s.add_dependency 'font-awesome-rails'
  s.add_dependency 'jquery-cookie-rails'
  s.add_dependency 'globalize-accessors'
  s.add_dependency 'rack-cache'
  s.add_dependency 'virtus'

  s.required_ruby_version = '>= 2.2.0'
end
