source 'https://rubygems.org'


# Read the ruby version for Heroku
File.open(File.expand_path('../.ruby-version', __FILE__), 'r') do |f|
  ruby f.read.strip
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.3'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer'

# For authentication
gem 'devise'
# For Learning Layers OIDC
gem 'omniauth-oauth2'
# For authorization
gem 'pundit'

# For HTTP requests to SSS
gem 'faraday'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# material style
gem 'material_design_lite-rails'

# Frontend things
gem 'lodash-rails'

# Full text search
gem 'pg_search'

# Better server
gem 'puma'

# Internationalization
gem 'rails-i18n', '~> 4.0.0'

group :development do
  # View sent emails
  gem 'letter_opener_web'
end

group :development, :test do
  # Better REPL
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-byebug'

  # Better tests
  gem 'rspec'
  gem 'rspec-rails'

  # Clear the database between tests
  gem 'database_cleaner'
end

group :production do
  # Adds Heroku-specific configuration for production environments.
  gem 'rails_12factor'
end
