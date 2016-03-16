if Rails.env.production?
  module OmniAuth
    module Strategy
      def full_host
        (ENV["ACHRAILS_SELF_URI"] || ENV["LAYERS_API_URI"] || '').chomp('/')
      end
    end
  end
end
