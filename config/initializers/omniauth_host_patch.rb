if Rails.env.production?
  module OmniAuth
    module Strategy
      def full_host
        ENV["HACK_URI"] || ENV["LAYERS_API_URI"]
      end
    end
  end
end
