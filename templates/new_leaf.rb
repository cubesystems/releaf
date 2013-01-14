# create rvmrc file

remove_file 'Gemfile'
create_file 'Gemfile'

add_source  'https://rubygems.org'

gem 'rails', '3.2.11'

gem "haml-rails"
gem "jquery-rails"
gem "mysql2"
gem 'acts_as_list', :git => 'https://github.com/miks/acts_as_list.git'
gem 'awesome_nested_set'
gem 'cancan', '~> 1.6.8'
gem 'devise', '~> 2.1.2'
gem 'dragonfly', '~> 0.9.12'
gem 'haml'
gem 'haml-rails'
gem 'i18n-leaf', :git => 'git@github.com:cubesystems/i18n-leaf.git'
gem 'leaf', :git => 'git@github.com:cubesystems/leaf.git'
gem 'rack-cache', :require => 'rack/cache'
gem 'rails-settings-cached', :git => 'https://github.com/graudeejs/rails-settings-cached'
gem 'strong_parameters'
gem 'tinymce-rails', '~> 3.5.8'
gem 'will_paginate', '~> 3.0.3'
gem 'yui-rails', :git => 'https://github.com/ConnectCubed-Open/yui-rails'
# Use unicorn as the app server
gem 'unicorn'

gem_group :assets do
  gem 'sass-rails',   '~> 3.2.5'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem_group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'rvm-capistrano'
  gem 'guard-spin'
  gem 'brakeman', '~>1.8.3'
  # gem 'debugger'
  # gem 'ruby-debug19', :require => 'ruby-debug'
  # gem 'better_errors'
  ## https://github.com/banister/binding_of_caller/issues/8
  # gem 'binding_of_caller'
end

gem_group :development, :test, :demo do
  gem 'rspec-rails'
  # gem 'cucumber-rails', require: false
  # gem 'cucumber'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'simplecov', :require => false, :platforms => :mri_19
  gem 'database_cleaner'
end

application 'config.active_record.whitelist_attributes = false'
gsub_file 'config/application.rb', /(config.active_record.whitelist_attributes =) true/, '\1 false'

remove_file 'db/seeds.rb'

create_file 'config/database.yml.example', <<-EOF
development:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: dev_#{app_name}
  pool: 5
  username: root
  socket: /tmp/mysql.sock

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test: &test
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: test_#{app_name}
  pool: 5
  username: root
  socket: /tmp/mysql.sock

production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}
  pool: 5
  username: rails
  #password: FIXME
  socket: /var/run/mysqld/mysqld.sock

demo:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: demo_#{app_name}
  pool: 5
  username: rails
  #password: FIXME
  socket: /tmp/mysql.sock

cucumber:
  <<: *test
  EOF

run "cp 'config/database.yml.example' 'config/database.yml'"

create_file ".rvmrc", "rvm 1.9.3@#{app_name}"
run "rvm gemset create #{app_name}"
# run "rvm gemset use #{appname}; bundle install"
run "bundle install"


rake 'db:drop'
rake 'db:create'

generate 'settings settings'
rake 'db:migrate'

generate 'leaf:install'
generate 'i18n:leaf:install'
rake 'db:migrate'
generate 'devise:install'

route "mount_leaf_at '/admin'"

remove_file 'public/index.html'
remove_file 'rm public/images/rails.png'

rake 'db:seed'


remove_file 'app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.haml', <<-EOF

EOF
