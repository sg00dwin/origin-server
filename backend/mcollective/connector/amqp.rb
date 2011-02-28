require 'cqpid'
require 'pp'

module MCollective

    module Connector

       class Amqp<Base
           attr_reader :connection

           def initialize
               @config = Config.instance
               @subscriptions = {}
               @log = Log.instance
           end

            def reconnect
                @log.debug("Reconnect attempt to qpidd")
                #puts "Reconnect attempt to qpidd"
                begin
		  subscriptions_new = {}
                  @subscriptions.each_key do |source|
                    receiver = @session.createReceiver("amq.direct#{source}")
                    subscriptions_new[source] = receiver
                  end
		  @subscriptions = subscriptions_new
                  @sender = @session.createSender("amq.direct")
                rescue Exception => e
                    @log.debug("Reconnect Exception #{e}")
                    sleep 1
                    retry
                end
            end

           def connect
               @log.debug("Connecton attempt to qpidd")
               if @connection
                   @log.debug("Already connection, not re-initializing connection")
                   return
               end

               # Parse out the config info
               url = "amqp:tcp:" + get_option("amqp.url")
               ha_url = "amqp:tcp:" + get_option("amqp.ha-url")
               reconnect_url = "{reconnect-urls: '#{ha_url}', reconnect:true, heartbeat:1}"

               @log.debug("Connecting to #{url}, #{reconnect_url}")
               @connection = Cqpid::Connection.new(url, reconnect_url)
               @connection.open
               @session = @connection.createSession
               
               # Set up the topic change
               @sender = @session.createSender("amq.direct")
               
               @log.info("AMQP Connection established")     
           end

            def receive
                begin
                    @log.debug("Waiting for a message...")
	            receiver = Cqpid::Receiver.new
		    while 1 do
                      break if @session.nextReceiver(receiver,Cqpid::Duration.SECOND)
                      sleep 0.01
                    end
                    msg = receiver.fetch()
                  
                    # For debugging - TO-DO remove
                    #@log.debug("Received message #{msg.getContent}")

                    @session.acknowledge
		    #puts "\n\n###Received and returning Content:\n #{msg.getContent}"
                    Request.new(msg.getContent)
                rescue StandardError => e
                    @log.debug("Caught Exception #{e}")
                    reconnect
                    retry
                end
            end

            def send(target, msg)
                begin
                  @log.debug("in send with #{target}")

                  # For debugging - TO-DO remove
                  #@log.debug("Sending a message to target 'amq.direct#{target}'")
                  #@log.debug("Sending message #{msg}")
		  #puts "\n\n###Sending Content:\n #{msg}"
               
                  @message = Cqpid::Message.new()
                  @message.setSubject(target[1..-1])
                  @message.setContent(msg)
                  @message.setContentType("text/plain")
                  @sender.send(@message);
                  @log.debug("Message sent")
                rescue StandardError => e
                    @log.debug("Caught Exception #{e}")
                    reconnect
                end
            end
            
            # Subscribe to a topic tor queue
            def subscribe(source)
                #puts "[amqp.rb] Subscription request for #{source}"
                @log.debug("Subscription request for #{source}")
                unless @subscriptions.include?(source)
                    new_source = "amq.direct" + source
                    @log.debug("Subscribing to #{new_source}")
                    receiver = @session.createReceiver(new_source)
                    receiver.setCapacity(10)
                    @subscriptions[source] = receiver
                end
                @log.debug("Current subscriptions #{@subscriptions}")
            end

            # Subscribe to a topic or queue
            def unsubscribe(source)
                #puts "[amqp.rb] in unsubscribe with #{source}"
                @log.debug("Unsubscribing #{source}")
                receiver = @subscriptions.delete(source)
                receiver.close
                @log.debug("Current subscriptions #{@subscriptions}")
            end

            # Disconnects from the Qpid connection
            def disconnect
                @log.debug("Disconnecting from Qpid")
                #puts "Disconnecting from Qpid" 

                # Cleanup the session
                begin
                    # @session.message_cancel(:destination => "messages")
                    # do we need something like 
                    # @session.sendFlush  ??
                    @session.sync
                    @session.close
                rescue Exception => e
                    @log.debug("Failed to cleanup session: #{e}")
                ensure
                    @session = nil
                end

                # Cleanup the connection
                begin
                    @connection.close
                rescue Exception => e
                    @log.debug("Failed to cleanup connection: #{e}")
                ensure
                    @connection = nil
                end
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
