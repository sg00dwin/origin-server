class ResultIO
  attr_accessor :debugIO, :resultIO, :messageIO, :errorIO, :appInfoIO, :exitcode, :data, :system_ssh_key, :cart_commands
  
  def initialize
    @debugIO = StringIO.new
    @resultIO = StringIO.new
    @messageIO = StringIO.new
    @errorIO = StringIO.new
    @appInfoIO = StringIO.new
    @data = ""
    @exitcode = nil
    @cart_commands = []
  end
  
  def append(resultIO)
    self.debugIO << resultIO.debugIO.string
    self.resultIO << resultIO.resultIO.string
    self.messageIO << resultIO.messageIO.string
    self.errorIO << resultIO.errorIO.string
    self.appInfoIO << resultIO.appInfoIO.string
    self.cart_commands += resultIO.cart_commands
    self
  end
  
  def to_s
    str = "--DEBUG--\n#{@debugIO.string}\n" +
          "--RESULT--\n#{@resultIO.string}\n" +
          "--MESSAGE--\n#{@messageIO.string}\n" +
          "--ERROR--\n#{@errorIO.string}\n" +
          "--APP INFO--\n#{@appInfoIO.string}\n" +
          "--EXIT CODE--\n#{@exitcode}\n" +
          "--CART COMMANDS--\n#{@cart_commands.join("\n")}\n"
  end
  
  def to_json(*args)
    reply = LegacyReply.new
    reply.debug = @debugIO.string
    reply.messages = @messageIO.string
    reply.result = @resultIO.string
    reply.data = @data
    reply.exit_code = @exitcode
    reply.to_json(*args)
  end
end

class LegacyReply < Cloud::Sdk::Model
  attr_accessor :api, :api_c, :broker, :broker_c, :debug, :messages, :result, :data, :exit_code  
  
  API_VERSION    = "1.1.1"
  API_CAPABILITY = %w(placeholder)
  C_VERSION      = "1.1.1"
  C_CAPABILITY   = %w(namespace rhlogin ssh app_uuid debug alter cartridge cart_type action app_name api)
  
  def initialize
    @api = API_VERSION
    @api_c = API_CAPABILITY
    @broker = C_VERSION
    @broker_c = C_CAPABILITY
    @debug = ""
    @messages = nil
  end
end