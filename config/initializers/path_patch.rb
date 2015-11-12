# Fix asset paths not being prefixed correctly
# From http://stackoverflow.com/questions/7293918/broken-precompiled-assets-in-rails-3-1-when-deploying-to-a-sub-uri
module Sprockets
  module Helpers
    module RailsHelper

      def asset_path(source, options = {})
        source = source.logical_path if source.respond_to?(:logical_path)
        path = asset_paths.compute_public_path(source, asset_prefix, options.merge(:body => true))
        path = options[:body] ? "#{path}?body=1" : path
        if !asset_paths.send(:has_request?)
          path = ENV['RAILS_RELATIVE_URL_ROOT'] + path if ENV['RAILS_RELATIVE_URL_ROOT']
        end
        path
      end

    end
  end
end
