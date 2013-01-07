## Leaf

Leaf is Admin interface for Rails projects

## Getting started

Leaf will work with Rails 3.2.
You can add it to your Gemfile with:
```ruby
gem 'i18n-leaf', :git => 'git@github.com:cubesystems/i18n-leaf.git'
gem 'leaf', :git => 'git@git.cubesystems.lv:leaf_rails.git'
```

Run the bundle command to install it.

After you install Leaf, you need to run the generator:
```console
rails generate i18n:leaf:install
rails generate leaf:install
rake db:migrate
```

The generator will install an initializer which describes Leaf routes and configuration options (not yet implemented)

Now you need to add something like
```ruby
mount_leaf_at '/admin'
```

Note that you should re-start your app here if you've already started it. Otherwise you'll run into strange errors.

## Admin generator

You can generate admin and role model and controllers wit
```console
rails generate leaf:admin
```

now you can customize new migrations and models to fit you needs. When you're done customizing device run
```console
rake db:migrate
```

and then add
```ruby
resources :admins
resources :roles
```

or you can write custom ones
