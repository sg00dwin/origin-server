$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'mcollective'
require 'libra'

World(MCollective::RPC)

Before do
    @options = {:disctimeout => 2,
                :timeout     => 5,
                :verbose     => false,
                :filter      => {"identity"=>[], "fact"=>[], "agent"=>[], "cf_class"=>[]},
                :config      => "test/etc/client.cfg"}
end
