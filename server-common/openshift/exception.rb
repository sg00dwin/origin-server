module Libra
  class LibraException < StandardError
    attr :exit_code
    def initialize(exit_code)
      @exit_code = exit_code
    end
  end
  class ConfigureException < LibraException; end
  class CartridgeException < LibraException; end
  class NodeException < LibraException; end
  class UserException < LibraException; end
  class UserValidationException < UserException; end
  class DNSException < LibraException; end
  class StreamlineException < LibraException
    def initialize
      @exit_code = 144
    end
  end
end
