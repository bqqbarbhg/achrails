require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

FORCE_BEARER =
"eyJhbGciOiJSUzI1NiJ9.eyJleHAiOjE0NDUzMzU0OTQsImF1ZCI6WyI1OTUyMzk2YS02NGM5LTQyN2MtOTdmMC1iZWMxOWM3Yzk1MWIiXSwiaXNzIjoiaHR0cHM6XC9cL2FwaS5sZWFybmluZy1sYXllcnMuZXVcL29cL29hdXRoMlwvIiwianRpIjoiMjUwOTU5MGUtZjVkMy00ODZjLTk5NTMtY2U5ZjVhODkzZTRhIiwiaWF0IjoxNDQ1MzMxODk0fQ.AeQ8UJkaadnZ97Q8zhj9e4n4eqH31Mz0QuikJZ3XPsa7GTRep8Yl8XZMZigCiO1GeB9DDUAB0qOKkeL2DoFf4eGQa_Gw0sAa_X6I9rfhSkI4UtSRciDY3Re1Hl-OIV6LEaxUXIcIEggzMLToluqymiar6UaPHYsj9xZ5HkrXAZY"

FORCE_SSS_URL = "http://test-ll.know-center.tugraz.at/layers.test"

SSS = (FORCE_BEARER || ENV["SSS_URL"] && !ENV["DISABLE_SSS"])

module Achrails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    if SSS
      config.autoload_paths << Rails.root.join('app/models/sss')
    else
      config.autoload_paths << Rails.root.join('app/models/acr')
    end

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Serve assets on Heroku
    config.serve_static_assets = true

    config.sass.load_paths << File.expand_path('lib/assets/stylesheets/')
  end
end
