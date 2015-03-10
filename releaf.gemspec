require File.expand_path('releaf-core/lib/releaf/version', __dir__)

Gem::Specification.new do |s|
  s.name        = "releaf"
  s.version     = Releaf::VERSION

  s.date        = '2014-11-28'
  s.summary     = "Administration interface for Ruby on Rails"
  s.description = "Administration interface for Ruby on Rails"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'

  s.files = Dir["{app,config,db,lib,templates}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency    'releaf-core'
  s.add_dependency    'releaf-i18n_database'
  s.add_dependency    'releaf-permissions'
  s.add_dependency    'releaf-content'

  s.add_development_dependency 'rspec-rails', '~> 3.0.2'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'syntax'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'with_model'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-nav'
  s.add_development_dependency 'spring', '~> 1.1.0'
  s.add_development_dependency 'spring-commands-rspec'

  s.required_ruby_version = '>= 2.1.0'
end
