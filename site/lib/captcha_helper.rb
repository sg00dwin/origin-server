module CaptchaHelper
  def valid?(args = {})
    if @captcha_type
      captcha = CaptchaHelper.captcha_class(@captcha_type)
      captcha.new(args).valid?
    else
      false
    end
  end

  def skip_captcha?
    Rails.configuration.captcha_secret.nil? or @captcha_secret == Rails.configuration.captcha_secret
  end

  class << self
    def registered_captchas
      @@registered_captchas ||= {}
    end

    # This is to ensure that we are using captchas that are registered with us and desired by the Rails config
    def available_captchas
      @@available_captchas ||= registered_captchas.select{|k,_| Rails.configuration.captcha_types.include?(k)}
    end

    def config
      @@config ||= YAML.load_file(File.join(Rails.root,'config','captcha.yml'))
    end

    # This is for captcha types to register themselves
    def register_captcha(type,args)
      registered_captchas[type] = args
    end

    # This is a stupid simple way to rescue because 1.8 doesnt have sample
    #   and 1.9 doesn't have choice, awesome...
    def random_captcha
      choices = available_captchas.keys
      choices.sample rescue choices.choice
    end

    def captcha_class(type)
      available_captchas[type.to_sym].presence
    end

    def configure
      # Let the available captchas configure themselves
      available_captchas.each do |key,klass|
        klass.configure(config[key])
      end
    end
  end
end

module CaptchaHelper
  class CaptchaStub
    attr_reader :request, :params
    def initialize(args)
      @request = args[:request]
      @params = args[:params]
    end
  end
end

require 'captcha_helper/picatcha'
require 'captcha_helper/recaptcha'
