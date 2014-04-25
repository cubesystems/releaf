require 'simplecov'
require 'simplecov-rcov'

if ENV["COVERAGE"]

  # SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  #   SimpleCov::Formatter::HTMLFormatter,
  #   SimpleCov::Formatter::RcovFormatter
  # ]

  SimpleCov.start 'rails' do
    add_group 'Validators', 'app/validators'
  end

end

# vim: set ft=ruby:
