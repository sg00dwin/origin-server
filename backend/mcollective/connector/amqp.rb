require "qpid"
require "socket"

module MCollective
    module Connector
        # Handles sending and receiving messages over the AMQP protocol, using Qpid
        #
        # This plugin supports version 0-10 and newer of the AMQP
        #
        # For all versions you can configure it as follows:
        #
        #    connector = amqp
        #    plugin.qpid.host = localhost
        #    plugin.qpid.port = 5672
        #
        class Amqp<Base
            attr_reader :connection

            def initialize
                @config = Config.instance
                @subscriptions = []

                @log = Log.instance
            end

            # Connects to the Qpid middleware
            def connect
                if @connection
                    @log.debug("Already connection, not re-initializing connection")
                    return
                end

                # Parse out the config info
                host = get_option("amqp.host")
                port = get_option("amqp.port", 5672).to_i

                @log.debug("Connecting to #{host}:#{port}")

                # Create a unique identifier for the various channels
                @uniquename = @config.identity + "_" + $$.to_s

                # Establish a new connection
                @connection = Qpid::Connection.new(TCPSocket.new(host, port))
                @connection.start(10)

                # Create a unique session
                @session = @connection.session(@uniquename)

                # Create a direct exchange
                @session.exchange_declare("mc-exchange", :type => "direct")

                # Declare a unique queue for communications
                @session.queue_declare(@uniquename)
                @log.debug("Using queue #{@uniquename}")

                # Bind the exchange to the queue so messages get mapped
                @session.exchange_bind(:exchange => "mc-exchange", :queue => @uniquename)

                # Subscribe this session to the queue, using a local
                # buffer called 'messages' for received messages
                @session.message_subscribe(:destination => "messages", :queue => @uniquename,
                      :accept_mode => @session.message_accept_mode.none)

                # Grab a handle to the local 'messages' buffer
                @incoming = @session.incoming("messages")

                # Enable incoming message flow
                @incoming.start()

                @log.info("AMQP Connection established")
            end

            # Receives a message from the Qpid connection
            def receive
                @log.debug("Waiting for a message...")
                msg = @incoming.get(1)
                @log.debug("Received message")
                Request.new(msg.body)
            end

            # Sends a message to the Qpid session
            def send(target, msg)
                @log.debug("Sending a message to target '#{target}'")
                dp = @session.delivery_properties(:routing_key => "#{target}")
                mp = @session.message_properties(:content_type => "text/plain")
                @session.message_transfer(:message => Qpid::Message.new(dp, mp, msg))
                @log.debug("Message sent")
            end

            # Subscribe to a topic or queue
            def subscribe(source)
                @log.debug("Subscription request for #{source}")
                unless @subscriptions.include?(source)
                    @log.debug("Subscribing to #{source}")
                    @session.exchange_bind(:queue =>  @uniquename, :binding_key => "#{source}")
                    @subscriptions << source
                end
                @log.debug("Current subscriptions #{@subscriptions}")
            end

            # Subscribe to a topic or queue
            def unsubscribe(source)
                @log.debug("Unsubscribing #{source}")
                @session.exchange_unbind(:queue => @uniquename , :binding_key => "#{source}")
                @subscriptions.delete(source)
                @log.debug("Current subscriptions #{@subscriptions}")
            end

            # Disconnects from the Qpid connection
            def disconnect
                @log.debug("Disconnecting from Qpid")
                @session.message_cancel(:destination => "messages")
                @session.close
                @connection.close
            end

            private
            # looks for a config option, accepts an optional default
            #
            # raises an exception when it cant find a value anywhere
            def get_option(opt, default=nil)
                return @config.pluginconf[opt] if @config.pluginconf.include?(opt)
                return default if default

                raise("No plugin.#{opt} configuration option given")
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
