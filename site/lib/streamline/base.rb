module Streamline
  class Base

    attr_accessor :email_address
    attr_reader :rhlogin, :ticket, :roles, :terms
    # expose the rhlogin field as login
    alias_attribute :login, :rhlogin

    def simple_user?
      streamline_type == :simple
    end
    def full_user?
      streamline_type == :full
    end
    def streamline_type
      @streamline_type
    end

    def initialize(opts={})
      opts.each_pair { |k,v| send("#{k}=", v) }
    end

    protected
      attr_writer :streamline_type
      attr_writer :ticket, :email_address, :terms

      def roles=(roles)
        self.streamline_type = if roles.include? 'simple_authenticated'
          :simple
        elsif roles.include? 'authenticated'
          :full
        else
          nil
        end
        @roles = roles
      end

      def rhlogin=(login)
        raise "rhlogin cannot be changed once set" unless @rhlogin.nil?
        @rhlogin = login
      end
  end
end
