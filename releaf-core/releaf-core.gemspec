$:.push File.expand_path("../lib", __FILE__)

require "releaf/version"

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

  s.add_dependency 'rails', '~> 4.0.0'
  s.add_dependency 'sass-rails', '>= 3.2.5'
  s.add_dependency 'jquery-rails', '~> 3.0.4'
  s.add_dependency 'jquery-ui-rails', '~> 4.1.0'
  s.add_dependency 'railties', '>= 3.1'
  s.add_dependency 'haml-rails', '>= 0.3.4'
  s.add_dependency 'dragonfly', '>= 0.9.12', '< 1.0.0'
  s.add_dependency 'devise', '>= 2.1.0'
  s.add_dependency 'rails-settings-cached', '>= 0.2.4'
  s.add_dependency 'tinymce-rails', '~> 3.5.8'
  s.add_dependency 'acts_as_list'
  s.add_dependency 'awesome_nested_set', '>= 3.0.0.rc.2'
  s.add_dependency 'stringex', '>= 1.5.1'
  s.add_dependency 'will_paginate', '>= 3.0.4'
  s.add_dependency 'font-awesome-rails', '>= 4.0.1.0'
  s.add_dependency 'gravatar_image_tag'
  s.add_dependency 'jquery-cookie-rails'
  s.add_dependency 'globalize-accessors'
  s.add_dependency 'uuidtools', '>= 2.1.4'
  s.add_dependency 'nokogiri', '>= 1.6.0'
  s.add_dependency 'rack-cache'


  s.add_dependency 'axlsx', '~> 2.0.1'
  s.add_dependency 'roo', '~> 1.12.2'
end
