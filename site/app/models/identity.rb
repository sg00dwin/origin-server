class Identity

  attr_accessor :id, :type, :email, :url

  def initialize(opts={})
    opts.each_pair do |k,v|
      send("#{k}=", v)
    end
  end

  def type_name
    type == :openshift ? 'OpenShift' : type.to_s.titleize
  end

  #
  # Return all of the identities associated with a user
  #
  def self.find(user)
    case
    when user.simple_user?:
      [Identity.new :id => user.login, :type => :openshift, :email => user.login]
    else
      [Identity.new :id => user.rhlogin, :type => :red_hat, :email => user.email_address, :url => red_hat_account_url]
    end
  end


  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  private
    class << self
      include CommunityHelper
    end
end
