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

  # FIX axlsx complaining about missing zip/zip
  s.add_dependency 'rubyzip', '>= 1.0.0'
  s.add_dependency 'zip-zip'


  s.add_dependency 'rails', '~> 4.2.0'
  s.add_dependency 'i18n', '>= 0.7.0'
  s.add_dependency 'sass-rails'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'railties'
  s.add_dependency 'haml-rails'
  s.add_dependency 'dragonfly'
  s.add_dependency 'rails-settings-cached'
  s.add_dependency 'ckeditor_rails'
  s.add_dependency 'acts_as_list'
  s.add_dependency 'awesome_nested_set'
  s.add_dependency 'will_paginate'
  s.add_dependency 'font-awesome-rails'
  s.add_dependency 'gravatar_image_tag'
  s.add_dependency 'jquery-cookie-rails'
  s.add_dependency 'globalize-accessors'
  s.add_dependency 'nokogiri'
  s.add_dependency 'rack-cache'
  s.add_dependency 'axlsx_rails', '~> 0.3.0'
  s.add_dependency 'roo'

  s.required_ruby_version = '>= 2.1.0'
end
