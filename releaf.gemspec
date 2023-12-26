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

  Releaf::GEMS.each do|gem|
    s.add_runtime_dependency gem, Releaf::VERSION
  end

  s.add_development_dependency 'rspec-rails', '~> 6.1 '
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'listen', '~>3.0'
  s.add_development_dependency 'capybara', '~> 3.0'
  s.add_development_dependency 'selenium-webdriver', '~> 4.0'
  s.add_development_dependency 'factory_bot', '~> 6.4'
  s.add_development_dependency 'syntax'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'
  s.add_development_dependency 'database_cleaner', '~> 2.0'
  s.add_development_dependency 'shoulda-matchers', '~> 6.0'
  s.add_development_dependency 'db-query-matchers'
  s.add_development_dependency 'coveralls', '~> 0.8'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'with_model', '~> 2.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'roo'
  s.add_development_dependency 'puma'

  s.required_ruby_version = '>= 2.5.0'
end
