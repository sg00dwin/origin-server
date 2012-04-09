module RestApi
  module Configuration
    @builtin = {
      :openshift => {
        :url => 'https://openshift.redhat.com/broker/rest',
        #:ssl_options => {},
        #:proxy => '',
        :authorization => :passthrough
      },
      :local => {
        :url => 'https://localhost/broker/rest'
      }
    }
    @builtin.freeze

    class << self
      def [](sym)
        @builtin[sym]
      end

      def activate(config=nil)
        config = case config
          when nil:
            :local
          when :none:
            return false
          when :external:
            begin
              symbol = :external
              path = File.expand_path('~/.openshift/api.yaml')
              Configuration[:openshift].with_indifferent_access.merge(YAML.load(IO.read(path)))
            rescue Exception => e
              raise RestApi::ApiNotAvailable, <<-EXCEPTION
The console is configured to use the external file #{path} (through config.stickshift = :external symbol in your environment file), but the file cannot be loaded.

By default you must only specify user and password in #{path}, but you can set any other attribute that the .stickshift config option accepts.

E.g. to connect to production OpenShift with a test account, you must only provide:

user: my_test_openshift_account@email.com
password: my_password

  #{e.message}
    #{e.backtrace.join("\n    ")}
---------------------------------
              EXCEPTION
            end
          when Symbol:
            symbol = config
            Configuration[config] || config
          else
            raise "Invalid argument to config.stickshift"
          end

        unless config && defined? config[:url]
          raise RestApi::ApiNotAvailable, <<-EXCEPTION

RestApi requires that Rails.configuration.broker be set to a symbol or broker configuration object.  Active configuration is #{Rails.env}

'#{config.inspect}' is not valid.

Valid symbols: #{RestApi::CONFIGURATIONS.each_key.collect {|k| ":#{k}"}.join(', ')}
Valid broker object:
  {
    :url => '' # A URL pointing to the root of the REST API, e.g. 
               # https://openshift.redhat.com/broker/rest
  }
          EXCEPTION
        end

        RestApi::Base.set_configuration(config, symbol)
        config.clone
      end
    end
  end
end
