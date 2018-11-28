require File.expand_path('lib/releaf/version', __dir__)
require File.expand_path('lib/releaf/gems', __dir__)

Gem::Specification.new do |s|
  s.name        = "releaf"
  s.version     = Releaf::VERSION

  s.summary     = "Administration interface for Ruby on Rails"
  s.description = "Administration interface for Ruby on Rails"
  s.authors     = ["CubeSystems"]
  s.email       = 'info@cubesystems.lv'
  s.homepage    = 'https://github.com/cubesystems/releaf'
  s.require_paths = %w(lib)
  s.license     = "MIT"

  s.files       = Dir["lib/**/*"] + ["LICENSE"]
  s.test_files  = Dir["spec/factories/**/*"] + Dir["spec/support/**/*"] + Dir["spec/*.rb"]

  Releaf::GEMS.each do|gem|
    s.add_dependency gem, Releaf::VERSION
  end

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'factory_girl_rails', '4.8.0'
  s.add_development_dependency 'syntax'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'shoulda-matchers', '~> 2.8'
  s.add_development_dependency 'db-query-matchers'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'with_model', '1.2.2'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-nav'
  s.add_development_dependency 'roo'

  s.required_ruby_version = '>= 2.2.0'
end
