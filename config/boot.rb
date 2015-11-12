ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# PgSearch crashes on production
# See: https://github.com/Casecommons/pg_search/issues/144
require 'pg_search'

ENV['RAILS_RELATIVE_URL_ROOT'] ||= '/achrails'