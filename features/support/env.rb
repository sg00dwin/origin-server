require 'mcollective'

World(MCollective::RPC)

Before do
    @options = {:disctimeout => 2,
                :timeout     => 5,
                :verbose     => false,
                :filter      => {"identity"=>[], "fact"=>[], "agent"=>[], "cf_class"=>[]},
                :config      => "features/support/etc/client.cfg"}

    @libra = rpcclient("libra", :options => @options)
    @libra.progress = false

    @rpc_facts = rpcclient("rpcutil", :options => @options)
    @rpc_facts.progress = false
end
