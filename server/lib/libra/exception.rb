module Libra
  class LibraException < StandardError; end  
  class ConfigureException < LibraException; end
  class CartridgeException < LibraException; end
  class UserException < LibraException; end
  class NodeException < LibraException; end
end
