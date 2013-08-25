require 'rbconfig'

def ask_wizard(question, default_value)
  value = ask (@current_recipe || "prompt").rjust(10) + "  #{question}"

  if value.blank?
    value = default_value
  end

  return value
end

file 'Gemfile', <<-GEMFILE
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source "https://rubygems.org"

gem "rails", "3.2.13"

# gems used by releaf
gem 'releaf', :git => 'git@github.com:cubesystems/releaf.git'
gem 'mysql2'

gem "unicorn"

group :assets do
 gem "sass-rails", "~> 3.2.5"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem "uglifier", ">= 1.0.3"
end

group :development do
  gem "capistrano"
  gem "capistrano-ext"
  gem "rvm-capistrano"
  gem "guard-spin"
  gem "brakeman", ">= 1.9.2"

  # gem 'debugger'
  # gem 'ruby-debug19', :require => 'ruby-debug'
  # gem 'better_errors'
  ## https://github.com/banister/binding_of_caller/issues/8
  # gem 'binding_of_caller'
end

group :development, :test, :demo do
  gem "rspec-rails"
  gem "capybara"
  gem "factory_girl_rails"
  gem "simplecov", :require => false, :platforms => :mri_19
  gem "database_cleaner"
end

GEMFILE

# collect dummy database config
if ENV['RELEAF_DUMMY_DB_USERNAME'].nil?
  db_username = ask_wizard("Database username? (leave blank to use the 'root')", 'root')
else
  db_username = ENV['RELEAF_DUMMY_DB_USERNAME']
end

if ENV['RELEAF_DUMMY_DB_PASSWORD'].nil?
  db_password = ask_wizard("Database password for '#{db_username}?'", '')
else
  db_password = ENV['RELEAF_DUMMY_DB_PASSWORD']
end

if ENV['RELEAF_DUMMY_DB_NAME'].nil?
  @current_recipe = "database"
  db_name = ask_wizard("MySQL database name (leave blank to use 'releaf_dummy')?", 'releaf_dummy')
else
  db_name = ENV['RELEAF_DUMMY_DB_NAME']
end

gsub_file "config/database.yml", /username: .*/, "username: #{db_username}"
gsub_file "config/database.yml", /database: dummy_/, "database: #{db_name}_"
gsub_file "config/database.yml", /password:/, "password: #{db_password}" unless db_password.blank?

gsub_file 'config/boot.rb', "'../../Gemfile'", "'../../../../Gemfile'"

files_to_remove = %w[
  public/index.html
  public/images/rails.png
  app/views/layouts/application.html.erb
  config/routes.rb
  app/assets/stylesheets/application.css
  app/assets/javascripts/application.js
]
run "rm -f #{files_to_remove.join(' ')}"

run 'rm -f "Gemfile" "public/robots.txt" ".gitignore"'
# in "test" env "true" cause to fail on install generators
gsub_file 'config/environments/test.rb', 'config.cache_classes = true', 'config.cache_classes = false'
rake 'db:create'

generate "releaf:install"
generate "dummy:install -f"

gsub_file 'config/application.rb', 'config.active_record.whitelist_attributes = true', 'config.active_record.whitelist_attributes = false'
application "config.i18n.fallbacks = true"

# in "test" env "true" cause to fail on install generators, revert to normall
gsub_file 'config/environments/test.rb', 'config.cache_classes = false', 'config.cache_classes = true'
rake 'db:migrate'
rake 'db:seed'
