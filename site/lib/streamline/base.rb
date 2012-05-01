module Streamline
  module Base

    attr_accessor :email_address
    attr_reader :rhlogin, :ticket, :roles, :terms

    def simple_user?
      streamline_type == :simple
    end

    protected
      attr_accessor :streamline_type
      attr_writer :ticket, :email_address, :terms

      def rhlogin=(login)
        raise "rhlogin cannot be changed once set" unless @rhlogin.nil?
        @rhlogin = login
      end
  end
end
