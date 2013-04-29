require 'simplecov'
require 'simplecov-rcov'

if ENV["COVERAGE"]

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]

  SimpleCov.start do
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/features/'
    add_filter '/lib/assets'
    add_filter '/lib/tasks'
    add_filter '/spec/'
    add_filter '/app/assets/'

    # add_group 'Models', 'app/models'
    # add_group 'Controllers', 'app/controllers'
    # add_group 'Helpers', 'app/helpers'
    # add_group 'Mailers', 'app/mailers'
    # add_group 'Views', 'app/views'
    # add_group 'lib', 'lib'


    ## when using cucumber enable this:
    # use_merging true
    # merge_timeout 3600 # defaults to 10 minutes
  end

end

# vim: set ft=ruby:
