Rails.application.config.tap do |config|
  config.captcha_secret = Console.config.env(:CAPTCHA_SECRET, 'zvw5LiixMB0I4mjk06aR')
  config.captcha_types = Console.config.env(:CAPTCHA_TYPES, Rails.env.test? ? [:recaptcha] : [:recaptcha,:picatcha])
end

CaptchaHelper.configure