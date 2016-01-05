# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

# Serve the rails app under a  prefix. Defaults to '/achrails'
prefix = ENV['RAILS_RELATIVE_URL_ROOT']
if prefix.present?
  map prefix do
    run Rails.application
  end
else
  run Rails.application
end

# Tell omniauth to prefix it's callbacks correctly
