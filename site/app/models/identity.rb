class Identity

  attr_accessor :id, :type, :email

  def initialize(opts={})
    opts.each_pair do |k,v|
      send("#{k}=", v)
    end
  end

  #
  # Return all of the identities associated with a user
  #
  def self.find(user)
    case
    when user.roles.include?('simple_authenticated'):
      [Identity.new :id => user.login, :type => :openshift, :email => user.login]
    else
      [Identity.new :id => user.rhlogin, :type => :red_hat_network, :email => user.email_address]
    end
  end

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
end
