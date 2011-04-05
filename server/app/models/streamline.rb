require 'cgi'
require 'uri'

class Streamline

  ERRORS = ['user_already_registered',
            'contact_customer_service',
            'email_required',
            'email_invalid',
            'password_required',
            'password_match_failure',
            'terms_not_accepted']

  def self.login_url
    URI.parse(Rails.configuration.streamline + "/login.html")
  end

  def self.register_url
    URI.parse(Rails.configuration.streamline + "/registration.html")
  end

  def self.request_access_url
    URI.parse(Rails.configuration.streamline + "/requestAccess.html")
  end

  def self.roles_url
    URI.parse(Rails.configuration.streamline + "/cloudVerify.html")
  end

  def self.email_confirm_url(key, login)
    query = "key=#{key}&emailAddress=#{CGI::escape(login)}"
    URI.parse(Rails.configuration.streamline + "/confirm.html?#{query}")
  end
end
