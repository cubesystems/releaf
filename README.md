## Releaf

Releaf is Admin interface for Rails projects.

Documentation: http://cubesystems.github.com/releaf/

wiki: https://github.com/cubesystems/releaf/wiki/_pages

## Getting started

Releaf will work with Rails 3.2.

First add Releaf gem to your Gemfile
```ruby
gem 'releaf', :git => 'git@github.com:cubesystems/releaf.git'
```

Run the bundle command to install it.

Releaf is using strong_params, so in your config/application.rb set

```ruby
config.active_record.whitelist_attributes = false
```

Then install with
```console
rails generate releaf:install
rake db:migrate
```

You might want to create default role and user
```console
rake db:seed
```

Now you need to add something like this for releaf itself and standart admin,
permissions controllers

```ruby
mount_releaf_at '/admin'
```

Note that you should re-start your app here if you've already started it. Otherwise you'll run into strange errors.

Now open "/admin" on your dev site and login with following credentials:
```
email: admin@example.com
password: password
```
