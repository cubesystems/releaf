require File.expand_path('lib/releaf/version', __dir__)

Gem::Specification.new do |s|
  s.name        = "releaf-core"
  s.version     = Releaf::VERSION

  s.summary     = "core gem for releaf"
  s.description = "Admin interface for RubyOnRails projects inspired by Leaf CMS"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'

  s.files             = `git ls-files`.split("\n")
  #s.files = Dir["{app,config,db,lib,templates}/**/*"] + ["LICENSE"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'sass-rails', '~> 5.0'
  s.add_dependency 'jquery-rails', '~> 4.2'
  s.add_dependency 'jquery-ui-rails', '~> 4.2.0'
  s.add_dependency 'railties', '~> 4.2'
  s.add_dependency 'haml-rails', '~> 0.9'
  s.add_dependency 'dragonfly', '~> 1.0'
  s.add_dependency 'rails-settings-cached', '~> 0.4'
  s.add_dependency 'ckeditor_rails', '~> 4.5'
  s.add_dependency 'acts_as_list', '~> 0.8'
  s.add_dependency 'awesome_nested_set', '>= 3.0.0.rc.2'
  s.add_dependency 'will_paginate', '~> 3.1'
  s.add_dependency 'font-awesome-rails', '~> 4.6'
  s.add_dependency 'gravatar_image_tag'
  s.add_dependency 'jquery-cookie-rails'
  s.add_dependency 'globalize-accessors', '~> 0.2'
  s.add_dependency 'globalize', '< 5.1.0'
  s.add_dependency 'uuidtools', '>= 2.1.4'
  s.add_dependency 'nokogiri', '>= 1.6.0'
  s.add_dependency 'rack-cache', '~> 1.0'
  s.add_dependency 'virtus', '~> 1.0'

  s.add_dependency 'axlsx_rails', '~> 0.5.2'
  s.add_dependency 'axlsx', '~> 3.0.0.pre'
  s.add_dependency 'roo', '~> 2.7.1'
  s.add_dependency 'roo-xls', '~> 1.2.0'

  s.required_ruby_version = '>= 2.1.0'
end
