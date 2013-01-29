require 'rack/picatcha'

module CaptchaHelper
  include Rack::Picatcha::Helpers
  class Picatcha < CaptchaStub
    include Rack::Picatcha::Helpers

    def valid?
      picatcha_valid?(params)
    end

    class << self
      def configure(args)
        Rails.configuration.middleware.use Rack::Picatcha, args
      end
    end
  end
end

CaptchaHelper.register_captcha(:picatcha, CaptchaHelper::Picatcha)
