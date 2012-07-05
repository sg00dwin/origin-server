module Streamline
  class Base
    include ActiveModel::Validations

    attr_accessor :email_address
    attr_accessor :promo_code, :password, :old_password, :password_confirm
    attr_reader :rhlogin, :ticket, :roles, :terms, :token
    # expose the rhlogin field as login
    alias_attribute :login, :rhlogin


    #
    # These validations may be more appropriate as specific method related checks
    #

    # Helper to allow mulitple :on scopes to validators
    def self.on_scopes(*scopes)
      scopes = scopes + [:create, :update, nil] if scopes.include? :save
      lambda { |o| scopes.include?(o.validation_context) }
    end

    validates :login, 
              :presence => true,
              :if => on_scopes(:reset_password)

    validates_format_of :email_address,
                        :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i,
                        :message => 'Invalid email address',
                        :if => on_scopes(:save)

    # Requires Ruby 1.9 for lookbehind
    #validates_format_of :email_address,
    #                    :with => /(?<!(ir|cu|kp|sd|sy))$/i,
    #                    :message => 'We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy'

    validates_each :email_address, :if => on_scopes(:save) do |record, attr, value|
      if value =~ /\.(ir|cu|kp|sd|sy)$/i
        record.errors.add attr, 'We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy'
      end
    end

    validates_length_of :password,
                        :minimum => 6,
                        :message => 'Passwords must be at least 6 characters',
                        :if => on_scopes(:save, :change_password)

    validates_confirmation_of :password,
                              :message => 'Passwords must match',
                              :if => on_scopes(:save, :change_password)


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
      attr_writer :ticket, :email_address, :terms, :token

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
        raise "rhlogin cannot be changed once set" if @rhlogin.present? && login != @rhlogin
        @rhlogin = login
      end
  end
end
