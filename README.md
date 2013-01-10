## Leaf

Leaf is Admin interface for Rails projects

## Getting started

Leaf will work with Rails 3.2.
You can add it to your Gemfile with:
```ruby
gem 'devise', '~> 2.1.2'
gem 'rails-settings-cached', :git => 'https://github.com/graudeejs/rails-settings-cached'

gem 'i18n-leaf', :git => 'git@github.com:cubesystems/i18n-leaf.git'
gem 'leaf', :git => 'git@github.com:cubesystems/leaf.git'
```

Run the bundle command to install it.

After you install Leaf, you need to run the generator:
```console
rails generate devise:install
rails generate leaf:install
rails generate i18n:leaf:install
rake db:migrate
```

The generator will install an initializer which describes Leaf routes and configuration options (not yet implemented)

Now you need to add something like
```ruby
mount_leaf_at '/admin'
```

for admin users add
```ruby
resources :admins
resources :roles
```
or you can write custom ones

Note that you should re-start your app here if you've already started it. Otherwise you'll run into strange errors.
