require 'streamline'
require 'streamline/railties/controller_runtime'
require 'streamline/log_subscriber'
require 'rack/utils'

ActiveSupport.on_load(:action_controller) do
  include Streamline::Railties::ControllerRuntime
end

Streamline::LogSubscriber.attach_to :streamline

#
# RedHat SSO infrastructure requires that rh_sso be presented exactly as
# returned by Streamline.  Allow this rails app to set cookies that are
# unescaped in Rack 1.3 (should be fixed in future versions of rack).
#
Rack::Utils.module_eval do
  def self.unescaped_cookies
    @unescaped ||= []
  end

  def set_cookie_header!(header, key, value)
    case value
    when Hash
      domain  = "; domain="  + value[:domain] if value[:domain]
      path    = "; path="    + value[:path]   if value[:path]
      # According to RFC 2109, we need dashes here.
      # N.B.: cgi.rb uses spaces...
      expires = "; expires=" + value[:expires].clone.gmtime.
        strftime("%a, %d-%b-%Y %H:%M:%S GMT") if value[:expires]
      secure = "; secure"  if value[:secure]
      httponly = "; HttpOnly" if value[:httponly]
      value = value[:value]
    end
    value = [value] unless Array === value
    cookie = escape(key) + "=" +
      value.map do |v|
        #
        # Allow some cookies to not be escaped
        #
        unescaped_cookies.include?(key.to_s) ? v : escape(v)
      end.join("&") + "#{domain}#{path}#{expires}#{secure}#{httponly}"

    case header["Set-Cookie"]
    when Array
      header["Set-Cookie"] = (header["Set-Cookie"] + [cookie]).join("\n")
    when String
      header["Set-Cookie"] = [header["Set-Cookie"], cookie].join("\n")
    when nil
      header["Set-Cookie"] = cookie
    end

    nil
  end
  module_function :set_cookie_header!
end

Rack::Utils.unescaped_cookies << 'rh_sso'
