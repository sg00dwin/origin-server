require 'cqpid'

module MCollective
  module Connector
    class Amqp<Base
      attr_reader :connection

      def initialize
        @config = Config.instance
        @subscriptions = {}
        @log = Log.instance
      end

      def connect
        @log.debug("Connection attempt to qpidd")
        if @connection
          @log.debug("Already connected. Not re-initializing connection")
          return
        end

        # Parse out the config info
        host = get_option("amqp.host")
        host_port = get_option("amqp.host.port", nil)
        ha_host = get_option("amqp.host.ha", nil)
        ha_host_port = get_option("amqp.host.ha.port", nil)

        secure = (get_option("amqp.secure", "false") == "true")

        # Default ports as necessary
        if secure
          host_port ||= 5671
          ha_host_port ||= 5671
        else
          host_port ||= 5672
          ha_host_port ||= 5672
        end

        url = "#{host}:#{host_port}"

        timeout = get_option("amqp.timeout", 5).to_i
        args = []
        if ha_host
          args << "reconnect-urls: '#{ha_host}:#{ha_host_port}'"
        end

        if secure
           args << "transport:ssl"
        end

        args << "reconnect:true"

        if timeout
          args << "reconnect-timeout:#{timeout}"
        end

        args << "heartbeat:1"

        amqp_options = "{#{args.join(', ')}}"
          
        @connection = nil

        begin
          @log.debug("Connecting to #{url},  #{amqp_options}")
          @connection = Cqpid::Connection.new((secure ? 'amqp:ssl:' : '') + url, amqp_options)
          @connection.open
        rescue StandardError => e
          @log.error("Initial connection failed... retrying")
          sleep 5
          retry
        end

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
            break if @session.nextReceiver(receiver,Cqpid::Duration.IMMEDIATE)
            raise "Need to reconnect" unless @session.getConnection().isOpen()
            sleep 0.01
          end
          msg = receiver.fetch()

          @log.debug("Received message")

          @session.acknowledge
          Request.new(msg.getContent)
        rescue StandardError => e
            @log.debug("Caught Exception #{e}")
            @session.sync
            retry
        end
      end

      def send(target, msg)
        begin
          @log.debug("in send with #{target}")
          @log.debug("Sending a message to target 'amq.direct#{target}'")

          @message = Cqpid::Message.new()
          @message.setSubject(target[1..-1])
          @message.setContent(msg)
          @message.setContentType("text/plain")
          @sender.send(@message);
          @log.debug("Message sent")
        rescue StandardError => e
          @log.debug("Caught Exception #{e}")
          @session.sync
        end
      end

      # Subscribe to a topic tor queue
      def subscribe(source)
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
        @log.debug("Unsubscribing #{source}")
        receiver = @subscriptions.delete(source)
        receiver.close
        @log.debug("Current subscriptions #{@subscriptions}")
      end

      # Disconnects from the Qpid connection
      def disconnect
        @log.debug("Disconnecting from Qpid")

        # Cleanup the session
        begin
          @session.sync
          @session.close
        rescue Exception => e
          @log.debug("Failed to cleanup session: #{e}")
        ensure
          @session = nil
        end

        # Clear the subscription cache
        @subscriptions = {}

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
      def get_option(opt, default=nil, allow_nil=true)
        return @config.pluginconf[opt] if @config.pluginconf.include?(opt)
        return default if (default or allow_nil)
        raise("No plugin.#{opt} configuration option given")
      end
    end
  end
end
