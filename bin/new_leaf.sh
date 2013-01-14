#!/usr/bin/env bash

app_name="`echo "$1" | sed -E 's/[^a-zA-Z0-9]/_/g'`"


if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  echo "ERROR: An RVM installation was not found" > /dev/stderr
  exit 1
fi



if [ "$app_name" == '' ]; then
  echo "ERROR: App name not given" > /dev/stderr
  exit 1
fi

AppName() {
  echo -n $app_name | sed -E '
    s/^a/A/; s/_a/A/g;
    s/^b/B/; s/_b/B/g;
    s/^c/C/; s/_c/C/g;
    s/^d/D/; s/_d/D/g;
    s/^e/E/; s/_e/E/g;
    s/^f/F/; s/_f/F/g;
    s/^g/G/; s/_g/G/g;
    s/^h/H/; s/_h/H/g;
    s/^i/I/; s/_i/I/g;
    s/^j/J/; s/_j/J/g;
    s/^k/K/; s/_k/K/g;
    s/^l/L/; s/_l/L/g;
    s/^m/M/; s/_m/M/g;
    s/^n/N/; s/_n/N/g;
    s/^o/O/; s/_o/O/g;
    s/^p/P/; s/_p/P/g;
    s/^q/Q/; s/_q/Q/g;
    s/^r/R/; s/_r/R/g;
    s/^s/S/; s/_s/S/g;
    s/^t/T/; s/_t/T/g;
    s/^u/U/; s/_u/U/g;
    s/^v/V/; s/_v/V/g;
    s/^w/W/; s/_w/W/g;
    s/^x/X/; s/_x/X/g;
    s/^y/Y/; s/_y/Y/g;
    s/^z/Z/; s/_z/Z/g;
  '
}

rails new $app_name --skip-gemfile --skip-bundle --database=mysql --skip-test-unit

cat << EOF > "$app_name/Gemfile"
source "https://rubygems.org"

gem "rails", "3.2.11"

gem "acts_as_list", :git => "https://github.com/miks/acts_as_list.git"
gem "awesome_nested_set"
gem "cancan", "~> 1.6.8"
gem "devise", "~> 2.1.2"
gem "dragonfly", "~> 0.9.12"
gem "haml"
gem "haml-rails"
gem "i18n-leaf", :git => "git@github.com:cubesystems/i18n-leaf.git"
gem "jquery-rails"
gem "leaf", :git => "git@github.com:cubesystems/leaf.git"
gem "mysql2"
gem "rack-cache", :require => "rack/cache"
gem "rails-settings-cached", :git => "https://github.com/graudeejs/rails-settings-cached"
gem "strong_parameters"
gem "tinymce-rails", "~> 3.5.8"
gem "unicorn"
gem "will_paginate", "~> 3.0.3"
gem "yui-rails", :git => "https://github.com/ConnectCubed-Open/yui-rails"

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
  gem "brakeman", "~>1.8.3"

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

EOF


cat << EOF > "$app_name/config/database.yml.example"
development:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: dev_${app_name}
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
  database: test_${app_name}
  pool: 5
  username: root
  socket: /tmp/mysql.sock

production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}
  pool: 5
  #username: FIXME
  #password: FIXME
  socket: /var/run/mysqld/mysqld.sock

demo:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: demo_${app_name}
  pool: 5
  username: rails
  #password: FIXME
  socket: /tmp/mysql.sock

cucumber:
  <<: *test
EOF
cp "$app_name/config/database.yml.example" "$app_name/config/database.yml"

rm -f "$app_name/db/seeds.rb" "$app_name/public/index.html" "$app_name/public/images/rails.png" "$app_name/app/views/layouts/application.html.erb"

cat << EOF > "$app_name/app/views/layouts/application.html.haml"
!!!
%html
  %head
    %meta{"http-equiv"=>"Content-Type", :content=>"text/html; charset=utf-8"}
    %title `AppName`
    -# = favicon_link_tag("/assets/favicon.ico")
    = stylesheet_link_tag "application"
  %body(class = "#{params[:controller].gsub('/', '__')}-controller #{params[:action]}-view #{I18n.locale}-locale")
    = yeild
    = javascript_include_tag "application"
EOF

echo "rvm 1.9.3@$app_name" > "$app_name/.rvmrc"
rvm gemset create "$app_name"
rvm gemset use "$app_name"

cd "$app_name"
gem install bundler

bundle install

bundle exec rake db:drop db:create

bundle exec rails g settings settings
bundle exec rake db:migrate

bundle exec rails g leaf:install
bundle exec rails g i18n:leaf:install
bundle exec rake db:migrate

bundle exec rails g devise:install

cat << EOF > config/routes.rb

`AppName`::Application.routes.draw do
  mount_leaf_at '/admin'

  namespace :admin do
    resources :admins, :roles do
      get   :confirm_destroy, :on => :member
      match :urls, :on => :collection
    end
  end

end
EOF

sed -E -i .orig 's/#?[ ]?config.active_record.whitelist_attributes[ ]?=[ ]?true/config.active_record.whitelist_attributes = false/' config/application.rb
rm -f config/application.rb.orig

bundle exec rake db:seed
git init .
git add .
git commit -a -m 'initialize project'
