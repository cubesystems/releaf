require 'simplecov'
require 'simplecov-rcov'
# SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
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
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.add_formatter(:html, 'rspec.html')
  config.add_formatter(:progress)


  config.include Rails.application.routes.url_helpers

  # DEVISE
  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
  config.include Devise::TestHelpers, :type => :helper
  config.extend ControllerMacros, :type => :helper

  config.include FeatureMacros, :type => :feature


  # FactoryGirl
  config.include FactoryGirl::Syntax::Methods

  Capybara.javascript_driver = :webkit

  config.before(:each) do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start
    # set settings
    Settings.i18n_locales  = %w[en]
    Settings.i18n_admin_locales = %w[en]
    I18n.locale = Settings.i18n_locales.first
    I18n.default_locale = Settings.i18n_locales.first
  end

  config.after do
    DatabaseCleaner.clean
  end
end

Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each { |f| require f }
