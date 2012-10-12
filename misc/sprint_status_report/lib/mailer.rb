#!/usr/bin/env ruby

require 'yaml'
require 'mail'
require 'ostruct'

module Status
  class Email
    attr_accessor :mail

    def initialize(opts)
      default_opts = OpenStruct.new(YAML.load_file(File.join(CONFIG_DIR,'mail.yml')))

      @mail = Mail.new do
        if ( _body = opts.delete(:body) )
          text_part do
            body _body
          end
        end
        if( _html = opts.delete(:html) )
          html_part do
            content_type 'text/html; charset=UTF-8'
            body _html
          end
        end
      end

      default_opts.msg_opts.merge(opts).each{|k,v| @mail[k] = v }

      type = (ENV['MAIL_TYPE'] || default_opts.mail_type).to_sym
      delivery_opts = default_opts.delivery_opts[type] || {}

      @mail.delivery_method type, delivery_opts
    end

    def deliver!
      @mail.deliver!
    end
  end
end
