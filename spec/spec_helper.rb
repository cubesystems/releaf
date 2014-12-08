require 'simplecov'
require 'simplecov-rcov'
require 'coveralls'
require 'pry'
require 'pry-nav'
SimpleCov.command_name 'rspec'

Coveralls.wear!('rails')

if ENV["COVERAGE"]
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/config/'
    add_filter '/lib/tasks'
    add_filter '/spec/'
    add_filter '/app/assets/'
  end
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'factory_girl'
require 'capybara/rspec'
require 'database_cleaner'
require 'capybara/poltergeist'
require 'shoulda-matchers'
require 'with_model'
require 'timecop'
require 'releaf/rspec'

Rails.backtrace_cleaner.remove_silencers!
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# for devise testing
include Warden::Test::Helpers


Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: true, inspector: true, phantomjs_logger: WarningSuppressor)
end

class WarningSuppressor
  IGNOREABLE = /CoreText performance|userSpaceScaleFactor/

  def write(message)
    if message =~ IGNOREABLE
      0
    else
      puts(message)
      1
    end
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.infer_spec_type_from_file_location!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.color = true

  if ENV['COVERAGE']
    config.add_formatter(:progress)
  end

  config.include Releaf::TestHelpers
  config.include WaitSteps
  config.include ExcelHelpers
  config.extend WithModel

  config.include Rails.application.routes.url_helpers

  # DEVISE
  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :controller
  config.include Devise::TestHelpers, type: :helper
  config.extend ControllerMacros, type: :helper


  # FactoryGirl
  config.include FactoryGirl::Syntax::Methods

  Capybara.javascript_driver = :poltergeist

  # disable empty translation creation
  Releaf::I18nDatabase.create_missing_translations = false

  config.before(:each) do
    if Capybara.current_driver == :rack_test && ENV['RELEAF_DB'] != 'postgresql'
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
    Timecop.return
    DatabaseCleaner.clean
  end
end

Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each { |f| require f }
