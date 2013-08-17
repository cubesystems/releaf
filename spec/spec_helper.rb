require 'simplecov'
require 'simplecov-rcov'
SimpleCov.command_name 'rspec'


development = !!ENV['GUARD_NOTIFY'] || !ENV["RAILS_ENV"]
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl'
require 'capybara/rspec'
require 'support/helpers'

Rails.backtrace_cleaner.remove_silencers!
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# for devise testing
include Warden::Test::Helpers

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.color_enabled = true

  if development
    config.add_formatter(:documentation)
  else
    config.add_formatter(:progress)
  end
  config.add_formatter(:html, 'rspec.html')

  config.include Helpers
  config.include WaitSteps

  config.include Rails.application.routes.url_helpers

  # DEVISE
  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
  config.include Devise::TestHelpers, :type => :helper
  config.extend ControllerMacros, :type => :helper


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
    I18n.locale = Releaf.available_locales.first
    I18n.default_locale = Releaf.available_locales.first
  end

  config.after do
    DatabaseCleaner.clean
  end
end

Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each { |f| require f }
