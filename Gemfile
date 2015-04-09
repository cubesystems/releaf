source "http://rubygems.org"

# Declare your gem's dependencies in releaf.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# gems re-listed for correct dummy app working

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

case ENV.fetch('RELEAF_DB', 'mysql')
when 'mysql'
  gem 'mysql2', platform: :ruby
  gem 'jdbc-mysql', platform: :jruby
  gem 'activerecord-jdbc-adapter', platform: :jruby
when 'postgresql'
  gem 'pg'
end

group :documentation do
  gem 'yard'
  gem 'github-markdown', '>= 0.5.3'
  gem 'redcarpet', '>= 2.2.2'
  gem 'yard-activerecord', '~> 0.0.14'
end
