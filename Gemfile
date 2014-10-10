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
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
end
