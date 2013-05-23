source "http://rubygems.org"

# Declare your gem's dependencies in releaf.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# gems re-listed for correct dummy app working
gem "rack-cache", :require => "rack/cache"
gem 'acts_as_list'
gem 'awesome_nested_set'
gem 'devise', '>= 2.1.0'
gem 'dragonfly', '>= 0.9.12'
gem 'globalize3'
gem 'haml'
gem 'haml-rails'
gem 'jquery-rails', '<= 2.1.4'
gem 'mysql2'
gem 'rack-cache', :require => 'rack/cache'
gem 'stringex'
gem 'strong_parameters', '= 0.1.6' # 0.2.0 is broken currently
gem 'tinymce-rails', '>= 3.5.8'
gem 'tinymce-rails-imageupload'
gem 'will_paginate', '>= 3.0.4'
gem 'rails-settings-cached'

group :development, :test, :demo do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'brakeman', '>= 1.9.2'
  gem 'rspec-rails', '>= 2.13.0'
  gem 'syntax'
  gem 'factory_girl_rails'
  gem 'simplecov', :require => false, :platforms => :mri_19
  gem 'simplecov-rcov'
  gem 'database_cleaner'
  gem 'shoulda-matchers'

  gem 'yard'
  gem 'redcarpet'
  # gem 'guard-spin'
  # gem 'guard-cucumber'
  # gem 'guard-yard'
end


# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
