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
  class UserAuthException < LibraException; end
  class UserValidationException < LibraException; end
  class DNSException < LibraException; end
end
