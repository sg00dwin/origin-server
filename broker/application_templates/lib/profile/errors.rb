# Overload initialize if you want different timeouts
module MyError
  attr_accessor :timeout, :wait, :fatal, :retry, :msg
  def initialize
    { :timeout => DEFAULT_TIMEOUT, :wait => DEFAULT_WAIT, :retry => true, :fatal => false }.each do |k,v|
      send("#{k}=",v)
    end
  end
end

# Not really an error, but used for consistancy
class Success < RuntimeError
  include MyError

  def initialize
    @retry = false
    @fatal = false
  end
end

class ServerError < RuntimeError
  include MyError

  def initialize
    super
    @timeout = 15*60
    @msg = "Unable to get response from HTTP server"
  end
end

class FatalServerError < RuntimeError
  include MyError

  def intialize
    super
    @fatal = true
    @msg = "There was a fatal server error"
  end
end

class DNSError < RuntimeError
  include MyError

  def initialize
    super
    @fatal = true
    @msg = "Unable to obtain address from DNS, giving up"
  end
end

class RHCError < RuntimeError
  include MyError

  def initialize
    super
    @fatal = true
    @msg = "Unable to find application using RHC, giving up"
  end
end

class NoCredentialsError < RuntimeError
  include MyError

  def initialize
    super
    @retry = false
    @fatal = true
    @msg = "No OpenShift credentials provided, unable to create application"
  end
end

class RestException < RuntimeError
  include MyError

  def initialize(msg)
    super()
    @retry = false
    @fatal = true
    @msg = msg
  end
end

class UnknownException < RuntimeError
  include MyError

  def initialize(msg)
    super()
    @retry = false
    @fatal = true
    @msg = msg
  end
end
