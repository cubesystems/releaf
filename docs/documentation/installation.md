---
title: Installation
weight: 1100
---

# Installing Releaf

Releaf requires Rails 4.2 or higher.

There are two ways of installing Releaf.

* use a prepared [automatic installation template](#automatic) to generate a new application
* [run the installer manually](#manual)

## Automatically installing Releaf from a template {#automatic}

Visit <https://github.com/cubesystems/releaf-bootstrap> and run the setup command provided.

It will create a new Git repository, set up Rails and Releaf and install a few often used things for the public website.

## Manually installing Releaf {#manual}

Add the Releaf gem to your Gemfile:

```ruby
gem 'releaf', github: 'cubesystems/releaf'
```

Run the bundle command to install the gem:

```console
bundle install
```

Run the Releaf installer that will generate all the needed files and database migrations:

```console
rails generate releaf:install
```

Run the generated database migrations:

```console
rake db:migrate
```

Create the default administrator roles and users:

```console
rake db:seed
```

Add Releaf routes to routes.rb:

```ruby
mount_releaf_at '/admin'
```

Restart your Rails application.


## After installation

Open `/admin` path on your development server, e.g. `http://localhost:3000/admin`

Sign in with `admin@example.com` as email and `password` as password.



