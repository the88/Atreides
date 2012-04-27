ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  require File.expand_path("../dummy/config/environment.rb",  __FILE__)
  module Jammit
    remove_const :PUBLIC_ROOT
    remove_const :ASSET_ROOT
    PUBLIC_ROOT = File.expand_path("../dummy/public", __FILE__)
    ASSET_ROOT = File.expand_path("../dummy", __FILE__)
  end
  Jammit.load_configuration(File.expand_path("../dummy/config/assets.yml",  __FILE__))
  require "rspec/rails"
  require "capybara/rspec"
  require "factory_girl"
  require "database_cleaner"

  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.default_url_options[:host] = "test.com"

  Rails.backtrace_cleaner.remove_silencers!

  # Configure capybara for integration testing
  require "capybara/rails"
  Capybara.default_driver   = :rack_test
  Capybara.default_selector = :css
  # Load support files
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
  Dir["#{File.dirname(__FILE__)}/factories/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    # Remove this line if you don't want RSpec's should and should_not
    # methods or matchers
    require 'rspec/expectations'

    # == Mock Framework
    config.mock_with :rspec

    # == Cleanup database
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end
    #config.before(:each) { DatabaseCleaner.start }
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

# Configure Rails Environment

# Load factories
