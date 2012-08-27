module Test
  class WebUser
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include ActiveModel::Serialization
    extend ActiveModel::Naming

    attr_accessor :login, :password, :ticket
    def initialize(opts={})
      opts.each_pair { |key,value| send("#{key}=", value) }
      @roles = []
    end
    def email_address=(address)
      login = address
      @email_address = address
    end
    def rhhogin
      login
    end
  end
end

class ActiveSupport::TestCase
  def set_user(user)
    session[:login] = user.login
    session[:user] = user
    session[:ticket] = user.ticket
    session[:streamline_type] = user.streamline_type if user.respond_to? :streamline_type
    @request.cookies['rh_sso'] = user.ticket
    @request.env['HTTPS'] = 'on'
    @user = user
  end
end
