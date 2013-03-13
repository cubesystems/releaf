## Releaf

Releaf is Admin interface for Rails projects.

Documentation: http://cubesystems.github.com/releaf/

## Getting started

Releaf will work with Rails 3.2.
You can add it to your Gemfile with:

```ruby
gem 'will_paginate', '~> 3.0.4'
gem 'acts_as_list'
gem 'awesome_nested_set'
gem 'cancan', '~> 1.6.8'
gem 'devise', '~> 2.1.2'
gem 'dragonfly', '~> 0.9.12'
gem 'globalize3'
gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'releaf', :git => 'git@github.com:cubesystems/releaf.git'
gem 'mysql2'
gem 'rack-cache', :require => 'rack/cache'
gem 'rails-settings-cached', :git => 'https://github.com/graudeejs/rails-settings-cached'
gem 'stringex'
gem 'strong_parameters'
gem 'tinymce-rails', '~> 3.5.8'
gem 'tinymce-rails-imageupload'
gem 'will_paginate', '~> 3.0.4'
gem 'yui-rails',  '~> 0.2.0'
```

Run the bundle command to install it.

Now in config/application.rb set

```ruby
config.active_record.whitelist_attributes = false
```

because releaf is expacting strog_params gem to be used

```console
rails generate settings settings
rake db:migrate
```

After you install Releaf, you need to run the generator:

```console
rails generate releaf:install
rails generate i18n:releaf:install
rake db:migrate
rails generate devise:install
```

The generator will install an initializer which describes Releaf routes and configuration options (not yet implemented)

Now you need to add something like this for releaf itself and standart admin,
permissions controllers

```ruby
mount_releaf_at '/admin'
namespace :admin do
  releaf_resources :admins, :roles
end
```

Add dragonfly initializer (/config/initializers/dragonfly.rb)

```ruby
require 'dragonfly/rails/images'
```

Note that you should re-start your app here if you've already started it. Otherwise you'll run into strange errors.
