## Releaf

Releaf is Admin interface for Rails projects.

Changelog: https://github.com/cubesystems/releaf/blob/master/CHANGELOG.md

[![Build Status](https://travis-ci.com/cubesystems/releaf.svg?branch=master)](https://travis-ci.com/cubesystems/releaf)
[![Coverage Status](https://coveralls.io/repos/cubesystems/releaf/badge.svg?branch=master)](https://coveralls.io/r/cubesystems/releaf?branch=master)
[![Code Climate](https://codeclimate.com/github/cubesystems/releaf.svg)](https://codeclimate.com/github/cubesystems/releaf)

## Getting started

Releaf works with Rails 6.1 and Ruby 3

First add Releaf gem to your Gemfile
```ruby
gem 'releaf', '~> 2.1'
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

## Testing
### Setup
Create `config.yml` (see examples in git root) and run
```console
rake dummy:setup
```
### Running rspec
```console
rspec .
````
or
```console
rake ci
```

### Cleanup
```console
rake dummy:remove
```


## New version releasing
1. bump version in `lib/releaf/version.rb`
2. write all changes and new version number in `CHANGELOG.md`
3. commit previous changes
4. create git version tag `ex: v1.0.12`
4. run `rake gem:build && rake gem:push`  
5. push new tag with `git push --tags`  
