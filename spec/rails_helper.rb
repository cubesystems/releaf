require 'simplecov'
require 'simplecov-rcov'
require 'coveralls'
require 'pry'
require 'pry-nav'
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
require 'factory_girl'
require "shoulda-matchers"
require 'db-query-matchers'
require 'capybara/poltergeist'
require 'with_model'
require 'timecop'
require 'with_model'
require 'database_cleaner'
require 'releaf/rspec'
require 'sass' # To stop these warnings: WARN: tilt autoloading 'sass' in a non thread-safe way; explicit require 'sass' suggested.

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

  config.color = true

  if ENV['COVERAGE']
    config.add_formatter(:progress)
  end

  config.include Releaf::Test::Helpers
  config.include WaitSteps
  config.include ExcelHelpers
  config.extend WithModel

  config.include Rails.application.routes.url_helpers

  # DEVISE
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.extend ControllerMacros, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.extend ControllerMacros, type: :helper


  # FactoryGirl
  config.include FactoryGirl::Syntax::Methods

  Capybara.javascript_driver = :poltergeist
  Capybara.server = :webrick

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
