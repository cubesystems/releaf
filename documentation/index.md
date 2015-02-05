---
title: Getting started
weight: 1
---

## Getting started

Releaf works with Rails 4.2

First add Releaf gem to your Gemfile

```ruby
gem 'releaf', github: 'cubesystems/releaf'
```

Run the bundle command to install it.

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
