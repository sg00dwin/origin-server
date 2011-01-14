require 'libra/server.rb'
require 'libra/user.rb'
require 'libra/helper.rb'
require 'libra/exception.rb'

module Libra
  attr_accessor :aws_key, :aws_secret, :rpc_opts, :logger
end
