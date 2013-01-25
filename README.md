## Leaf

Leaf is Admin interface for Rails projects

## Getting started

Leaf will work with Rails 3.2.
You can add it to your Gemfile with:
```ruby
gem 'leaf', :git => 'git@github.com:cubesystems/leaf.git'
gem 'rails-settings-cached', :git => 'https://github.com/graudeejs/rails-settings-cached'
gem 'mysql2'
gem 'will_paginate', '3.0.3'
gem 'devise', '~> 2.1.2'
gem 'haml'
gem 'haml-rails'
gem 'dragonfly', '~>0.9.12'
gem 'strong_parameters'
gem 'tinymce-rails', '~> 3.5.8'
gem 'yui-rails', :git => 'https://github.com/ConnectCubed-Open/yui-rails'
gem 'cancan', '~> 1.6.8'
gem 'awesome_nested_set'
gem 'acts_as_list'
gem 'globalize3'
gem 'stringex'
gem 'jquery-rails'
gem 'rack-cache', :require => 'rack/cache'
```

Run the bundle command to install it.

Now in config/application.rb set
```ruby
  config.active_record.whitelist_attributes = false
```
because leaf is expacting strog_params gem to be used


```console
rails generate settings settings
rake db:migrate
```


After you install Leaf, you need to run the generator:
```console
rails generate leaf:install
rails generate i18n:leaf:install
rake db:migrate
rails generate devise:install
```

The generator will install an initializer which describes Leaf routes and configuration options (not yet implemented)

Now you need to add something like this for leaf itself and standart admin,
permissions controllers
```ruby
  mount_leaf_at '/admin'
  namespace :admin do
    resources :admins, :roles do
        get :confirm_destroy, :on => :member
        match :urls, :on => :collection
      end
  end
```

Add dragonfly initializer (/config/initializers/dragonfly.rb)
```ruby
require 'dragonfly/rails/images'
```

Note that you should re-start your app here if you've already started it. Otherwise you'll run into strange errors.
