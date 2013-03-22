require 'simplecov'
SimpleCov.command_name 'rspec'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl'
require 'capybara/rspec'
Rails.backtrace_cleaner.remove_silencers!
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  # DEVISE
  config.include Devise::TestHelpers, :type => :controller

  # FactoryGirl
  config.include FactoryGirl::Syntax::Methods
end

Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each { |f| require f }
