require 'simplecov'
require 'simplecov-rcov'
require 'coveralls'
require 'pry'
SimpleCov.command_name 'rspec'

Coveralls.wear!('rails')

if ENV["COVERAGE"]
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter,
    Coveralls::SimpleCov::Formatter
  ])
  SimpleCov.start do
    add_filter '/lib/releaf/rspec'
    add_filter '/spec/'
  end
end

ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rails-controller-testing'
require 'factory_bot'
require "shoulda-matchers"
require 'db-query-matchers'
require 'selenium/webdriver'
require 'with_model'
require 'timecop'
require 'with_model'
require 'database_cleaner'
require 'releaf/rspec'

Rails.backtrace_cleaner.remove_silencers!
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# for devise testing
include Warden::Test::Helpers

Capybara.register_driver(:chrome) do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--window-size=1400,900')

  if ENV['CI']
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome
Capybara.default_max_wait_time = 5

Capybara.default_set_options = { clear: :backspace } # needed for 'fill_in "Foo", with: ""' to work

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.infer_spec_type_from_file_location!

  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::ActiveRecord, type: :model
  config.include Shoulda::Matchers::Independent

  config.color = true

  if ENV['COVERAGE']
    config.add_formatter(:progress)
  end

  config.include Releaf::Test::Helpers
  config.include CapybaraActions, type: :feature
  config.include WaitSteps
  config.include ExcelHelpers
  config.extend WithModel

  config.include Rails.application.routes.url_helpers

  # DEVISE
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.extend ControllerMacros, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.extend ControllerMacros, type: :helper


  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, type: type
    config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
    config.include ::Rails::Controller::Testing::Integration, type: type
  end


  config.include FactoryBot::Syntax::Methods

  Capybara.default_normalize_ws = true
  Capybara.server = :puma, { Silent: true }

  # disable empty translation creation

  config.before(:each) do |example|
    Rails.cache.clear
    allow( Releaf.application.config.i18n_database ).to receive(:translation_auto_creation).and_return(false)

    if example.metadata[:db_strategy]
      DatabaseCleaner.strategy = example.metadata[:db_strategy]
    elsif Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end

    DatabaseCleaner.start
    # set settings
    I18n.locale = Releaf.application.config.available_locales.first
    I18n.default_locale = Releaf.application.config.available_locales.first
  end

  config.after do
    Timecop.return
    DatabaseCleaner.clean
    Releaf::Test.reset!
  end
end

Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each { |f| require f }
