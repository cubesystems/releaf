require 'rbconfig'

dummy = ( app_name == 'dummy' )

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

gem "jquery-rails"
gem "rack-cache", :require => "rack/cache"
gem 'acts_as_list'
gem 'awesome_nested_set'
gem 'devise', '~> 2.1.2'
gem 'dragonfly', '~>0.9.12'
gem 'globalize3'
gem 'easy_globalize3_accessors', :git => 'https://github.com/paneq/easy_globalize3_accessors.git'
gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'releaf', :git => 'git@github.com:cubesystems/releaf.git'
gem 'mysql2'
gem 'rack-cache', :require => 'rack/cache'
gem "rails-settings-cached", "0.2.4"
gem 'stringex'
gem 'strong_parameters'
gem 'tinymce-rails', '~> 3.5.8'
gem 'tinymce-rails-imageupload'
gem 'will_paginate', '~> 3.0.4'
gem 'font-awesome-rails'
gem 'gravatar_image_tag'
gem 'jquery-cookie-rails'

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

if dummy
  if ENV['DUMMY_DATABASE_FILE']
    run 'cp ' + ENV['DUMMY_DATABASE_FILE'] + ' config/database.yml'
  else
    @current_recipe = "database"
    mysql_username = ask_wizard("Username for MySQL? (leave blank to use the 'root')", 'root')
    gsub_file "config/database.yml", /username: .*/, "username: #{mysql_username}"

    mysql_password = ask_wizard("Password for MySQL user #{mysql_username}?", '')
    gsub_file "config/database.yml", /password:/, "password: #{mysql_password}"

    mysql_database = ask_wizard("MySQL database name (leave blank to use 'releaf_dummy')?", 'releaf_dummy')
    gsub_file "config/database.yml", /database: dummy_/, "database: #{mysql_database}_"
  end
  gsub_file 'config/boot.rb', "'../../Gemfile'", "'../../../../Gemfile'"
else
  @current_recipe = "database"
  mysql_username = ask_wizard("Username for MySQL? (leave blank to use the 'root')", 'root')
  gsub_file "config/database.yml", /username: .*/, "username: #{mysql_username}"

  mysql_password = ask_wizard("Password for MySQL user #{mysql_username}?", '')
  gsub_file "config/database.yml", /password:/, "password: #{mysql_password}"

  run 'cp config/database.yml config/database.yml.example'
  append_file '.gitignore', 'config/database.yml'
end


files_to_remove = %w[
  db/seeds.rb
  public/index.html
  public/images/rails.png
  app/views/layouts/application.html.erb
  config/routes.rb
  app/assets/stylesheets/application.css
  app/assets/javascripts/application.js
]
run "rm -f #{files_to_remove.join(' ')}"


if dummy
  run 'rm -f "Gemfile" "public/robots.txt" ".gitignore"'

  # in "test" env "true" cause to fail on install generators
  gsub_file 'config/environments/test.rb', 'config.cache_classes = true', 'config.cache_classes = false'

else
  # load in RVM environment
  if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
    begin
      rvm_path     = File.dirname(File.dirname(ENV['MY_RUBY_HOME']))
      rvm_lib_path = File.join(rvm_path, 'lib')

      rvm_version = Gem::Version.new(`rvm --version`[/rvm (\d\.\d+\.\d+)/, 1].to_s)

      if rvm_version < Gem::Version.new('1.12.0')
        # RVM's ruby drivers were factored out into a gem
        # in 1.12.0, so you don't use this trick anymore.
        $LOAD_PATH.unshift rvm_lib_path
      end

      require 'rvm'
    rescue LoadError
      # RVM is unavailable at this point.
      raise "RVM ruby lib is currently unavailable."
    end
  else
    raise "RVM ruby lib is currently unavailable."
  end

  # create ruby version meta files
  file ".ruby-version", "ruby-2.0.0"

  # create ruby gemset meta files
  file ".ruby-gemset", "#{app_name}"

  say "Creating RVM gemset #{app_name}"
  RVM.gemset_create app_name

  say "Switching to use RVM gemset #{app_name}"
  RVM.gemset_use! app_name

  if run("gem list --installed bundler", :capture => true) =~ /false/
    run "gem install bundler --no-rdoc --no-ri"
  end

  run 'bundle install'
end
rake 'db:create'

generate "settings settings"
generate "devise:install"
generate "releaf:install #{ARGV.join(' ')}"
rake 'db:migrate'

file 'config/initializers/dragonfly.rb', "require 'dragonfly/rails/images'"
gsub_file 'config/application.rb', 'config.active_record.whitelist_attributes = true', 'config.active_record.whitelist_attributes = false'
application "config.i18n.fallbacks = true"

file 'config/routes.rb', <<-ROUTES
#{app_name.capitalize}::Application.routes.draw do
  mount_releaf_at '/admin'

  namespace :admin do
    releaf_resources :admins, :roles
  end

  root :to => 'home#index'

end
ROUTES

if dummy
  # in "test" env "true" cause to fail on install generators, revert to normall
  gsub_file 'config/environments/test.rb', 'config.cache_classes = false', 'config.cache_classes = true'
  generate "dummy:install -f"
  rake 'db:migrate'
  rake 'db:seed'
else
  rake 'db:seed'
  run 'git init .'
  run 'git add .'
  run 'git commit -a -m "initialize project"'

  say <<-SAY
    ===================================================================================
     Your new Releaf application is now installed and admin interface mounts at '/admin'
    ===================================================================================
  SAY
end
