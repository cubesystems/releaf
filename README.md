## LeafRails

LeafRails is Admin interface for Rails projects

## Getting started

LeafRails will work with Rails 3.2.
You can add it to your Gemfile with:
```ruby
gem 'i18n-leaf', :git => 'git@github.com:cubesystems/i18n-leaf.git'
gem 'leaf_rails', :git => 'git@git.cubesystems.lv:leaf_rails.git'
```

Run the bundle command to install it.

After you install LeafRails, you need to run the generator:
```console
rails generate i18n:leaf:install
rails generate leaf_rails:install
rake db:migrate
```

The generator will install an initializer which describes LeafRails routes and configuration options (not yet implemented)

Note that you should re-start your app here if you've already started it. Otherwise you'll run into strange errors.
