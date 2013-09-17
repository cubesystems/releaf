$:.push File.expand_path("../lib", __FILE__)

require "releaf/version"

Gem::Specification.new do |s|
  s.name        = "releaf"
  s.version     = Releaf::VERSION

  s.date        = '2013-03-23'
  s.summary     = "Admin interface for RubyOnRails projects"
  s.description = "Admin interface for RubyOnRails projects inspired by Leaf CMS"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'

  s.files = Dir["{app,config,db,lib,templates}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '= 3.2.13'
  s.add_dependency 'sass-rails', '>= 3.2.5'
  s.add_dependency 'jquery-rails', '= 2.3.0'
  s.add_dependency 'railties', '>= 3.1'
  s.add_dependency 'haml-rails', '>= 0.3.4'
  s.add_dependency 'dragonfly', '>= 0.9.12'
  s.add_dependency 'devise', '>= 2.1.0'
  s.add_dependency 'rails-settings-cached', '>= 0.2.4'
  s.add_dependency 'tinymce-rails', '~> 3.5.8'
  s.add_dependency 'acts_as_list'
  s.add_dependency 'awesome_nested_set'
  s.add_dependency 'i18n', '>= 0.6.0'
  s.add_dependency 'stringex', '>= 1.5.1'
  s.add_dependency 'will_paginate', '>= 3.0.4'
  s.add_dependency 'font-awesome-rails'
  s.add_dependency 'gravatar_image_tag'
  s.add_dependency 'jquery-cookie-rails'
  s.add_dependency 'easy_globalize3_accessors', '~> 1.3.2'
  s.add_dependency 'uuidtools', '>= 2.1.4'
  s.add_dependency 'nokogiri', '>= 1.6.0'


  s.add_dependency 'axlsx', '~> 2.0.1'
  s.add_dependency 'roo', '~> 1.12.2'

  # v0.2.0 is broken currently
  s.add_dependency 'strong_parameters', '= 0.1.6'

  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-webkit'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'syntax'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'brakeman'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'timecop'

  s.add_development_dependency 'yard'
  s.add_development_dependency 'github-markdown', '>= 0.5.3'
  s.add_development_dependency 'redcarpet', '>= 2.2.2'
end
