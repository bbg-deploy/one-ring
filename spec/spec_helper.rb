require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'factory_girl'
  require 'rspec/rails'
  require 'capybara/rails'
  require 'webmock/rspec'
  require 'email_spec'
  require 'database_cleaner'
  
  Dir[Rails.root.join("spec/api/**/*.rb")].each {|f| require f}
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # Don't allow our tests to make outgoing web requests
  WebMock.disable_net_connect!
  #WebMock.allow_net_connect!
  
  RSpec.configure do |config|
    # Mock Framework
    config.mock_with :rspec
  
    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
  
    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = true
  
    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
  
    # *** IMPORTANT ***
    #----------------------------------------------------------------------------
    # Extend is for methods that act in groups, not in examples 
    # (e.g. calling a method before any it..end statement)
    # Include is for methods that act in examples
    # (e.g. inside of an it..end statement)
  
    # For Models
    config.extend ModelSharedExamples, :type => :model
    config.extend AbilitySharedExamples, :type => :model
    config.extend AssociationSharedExamples, :type => :model
    config.extend AttributeSharedExamples, :type => :model
    config.extend NotificationSharedExamples, :type => :model
    # Concerns
    config.extend AuthenticationSharedExamples, :type => :model
  
    # For Controllers
    config.extend ControllerSharedExamples, :type => :controller
    config.extend ControllerSharedContexts, :type => :controller
    config.include ControllerMacros, :type => :controller
    config.include ControllerTestMacros, :type => :controller
    config.include Devise::TestHelpers, :type => :controller
  
    # For Features
    config.extend FeatureSharedContexts, :type => :feature
    config.include FeatureMacros, :type => :feature
    config.include Warden::Test::Helpers, :type => :feature

    # Global Macros & Helpers
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
    config.include(MailerMacros)
    config.include(WebmockMacros)
    config.include(GarbageCollection)
      
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end
    
    config.before(:each) do
      ActiveRecord::Base.observers.disable :all # <-- Turn 'em all off!
      reset_email
      webmock_geocoder
      webmock_twilio_successful   
      webmock_authorize_net_all_successful
    end

    config.after(:each) do
      begin_gc_deferment
      reconsider_gc_deferment
      scrub_instance_variables
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload 
end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.
