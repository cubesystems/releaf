require File.expand_path('releaf-core/lib/releaf/version', __dir__)

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

  s.add_dependency    'releaf-core', Releaf::VERSION
  s.add_dependency    'releaf-i18n_database', Releaf::VERSION
  s.add_dependency    'releaf-permissions', Releaf::VERSION
  s.add_dependency    'releaf-content', Releaf::VERSION

  s.add_development_dependency 'rspec-rails', '~> 0'
  s.add_development_dependency 'capybara', '~> 0'
  s.add_development_dependency 'poltergeist', '~> 0'
  s.add_development_dependency 'factory_girl_rails', '~> 0'
  s.add_development_dependency 'syntax', '~> 0'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'simplecov-rcov', '~> 0'
  s.add_development_dependency 'database_cleaner', '~> 0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.8'
  s.add_development_dependency 'db-query-matchers', '~> 0'
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'timecop', '~> 0'
  s.add_development_dependency 'with_model', '~> 0'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'pry-nav', '~> 0'
  s.add_development_dependency 'roo', '~> 0'

  s.required_ruby_version = '>= 2.2.0'
end
