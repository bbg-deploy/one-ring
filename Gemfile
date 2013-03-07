source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# For Postgresql
gem 'pg', :require => 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  #Foundation
  gem 'compass-rails', '>= 1.0.3'
  gem 'zurb-foundation', '~> 4.0.3'

  #Other
  gem 'uglifier', '>= 1.0.3'
end

gem 'slim', '~> 2.0.0.pre.6'
gem 'haml-rails', '>= 0.3.5'
gem 'jquery-rails', '~> 2.1'
gem 'jquery-ui-rails', '~> 2.0.0'
gem 'jquery_datepicker'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

group :development, :test do
  gem 'win32console'
  gem "spork-rails"
  gem 'rspec-rails', '~> 2.0'
  gem 'capybara', '>= 2.0.1'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'brakeman', '~> 1.8.0'
  gem 'timecop', '>= 0.5.7'  
  gem 'heroku_san', '~> 4.2.3'
end

group :test do
  gem 'email_spec', '>= 1.3.0'
  gem 'database_cleaner'
  gem 'webmock', '>= 1.9.0'
  gem 'shoulda-matchers', '>= 1.4.2'
#  gem 'shoulda-matchers', :github => 'thoughtbot/shoulda-matchers'
#  gem 'sms-spec', '~> 0.1.6'
end

# Encryption
# gem 'symmetric-encryption'

# API
gem 'grape', '~> 0.2.6'
#gem 'doorkeeper', '~> 0.6.7'

# Authentication & SSO
gem 'devise', '>= 2.2.3'
gem 'doorkeeper', '~> 0.6.7'

# Authorization & Role Management
gem 'rolify', '~> 3.1'
gem 'cancan', '~> 1.6.9'

#Tableless Models
gem 'activerecord-tableless', '~> 1.2.0'

# Exception Handling
gem 'exception_notification', '>= 3.0.0'

# Payment Gems
gem 'activemerchant', '~> 1.29.3', :require => 'active_merchant'

# Third Party Integration
gem 'sendgrid', '~> 1.0.0'
gem 'hello_sign', '~> 0.6.0'
gem 'twilio-ruby', '~> 3.9.0'

# Security Gems
gem 'strong_parameters', '>= 0.1.6'

# For PDFs
gem 'prawn'

# Gems for seeding
gem 'seedbank', '~> 0.2.0'

# Gems for improving the UX
gem 'friendly_id', '~> 4.0.8'

# Gems for formatting & relationships
gem 'numbers_and_words', '~> 0.4.0'
#TODO: Faze out fuzzy_match in favor of fuzzy_string_match
gem 'fuzzy_match', '~> 1.4.0'
gem 'fuzzy-string-match_pure', '>= 0.9.4'
gem 'acts_as_list', '~> 0.1.8'
gem 'awesome_nested_set', '>= 2.1.4'
gem 'ffaker', '~> 1.15.0'

# Gems for validating types of input
gem 'validates_existence', '>= 0.4'
gem 'validates_timeliness', '~> 3.0'
gem 'enumerize', '>= 0.5.0'
gem 'going_postal', '~> 0.1.1'
gem 'carmen-rails', '~> 1.0.0.beta3'
gem 'geocoder', '~> 1.1.2'

# Simple Form for easier form creation
gem 'simple_form', '~> 2.0.2'
gem 'nested_form', '~> 0.3.0'
gem 'wicked', '~> 0.3.2'
#TODO: Look into using this instead of nested_form
gem 'cocoon', '~> 1.0.22'