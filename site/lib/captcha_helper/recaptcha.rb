require 'rack/recaptcha'

module CaptchaHelper
  include Rack::Recaptcha::Helpers
  class Recaptcha < CaptchaStub
    include Rack::Recaptcha::Helpers

    def valid?
      recaptcha_valid?
    end

    class << self
      def configure(args)
        Rails.configuration.middleware.use Rack::Recaptcha, args
      end
    end
  end
end

CaptchaHelper.register_captcha(:recaptcha, CaptchaHelper::Recaptcha)
