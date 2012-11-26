module Streamline
  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    module ClassMethods
      def api_attribute_map
        @api_attribute_map ||= {}
      end

      def streamline_attribute_list
        @streamline_attribute_list ||= []
      end

      def set_streamline_attribute(object_attribute)
        unless @streamline_attribute_list.include?(object_attribute)
          @streamline_attribute_list << object_attribute
        end
      end

      def has_streamline_attribute?(object_attribute)
        @streamline_attribute_list.include?(object_attribute)
      end

      def set_api_attribute_map(object_attribute, api_attribute)
        @api_attribute_map[object_attribute] = api_attribute
      end

      def get_api_attribute_map(object_attribute)
        @api_attribute_map.has_key?(object_attribute) ? @api_attribute_map[object_attribute] : object_attribute
      end

      # Currently, the streamline promoteUser API accepts lowerCamelCase input arguments,
      # but emits lower_underscored error codes of the form:
      #
      #    <field_name>_<condition>
      #
      # in addition to a few special cases:
      # * key_mismatch - this is a config error case that is raise()-worthy
      # * password_match_failure - this is handled by I18n lookup
      # * address_required - notable because it doesn't match the field it is meant for: address1
      #
      # This code will need to employ self.attribute_map if/when the streamline API error codes
      # are made internally consistent with the input args.
      def errors_to_attributes(error_object, error_list)
        error_list.each do |error|
          # Call shenanigans on a bogus/missing secret key
          raise Streamline::PromoteInvalidSecretKey if error == 'key_mismatch'

          if error == 'password_match_failure'
            msg = I18n.t error, :scope => :streamline, :default => I18n.t(:unknown)
            error_object.add(:base, msg)
            next
          end

          unless field_match = error.match(/(\w+)_required/)
            error_object.add(:base, error)
            next
          end

          attr = field_match[1] == 'address' ? :address1 : field_match[1].to_sym

          unless has_streamline_attribute? attr
            error_object.add(:base, error)
            next
          end

          error_object.add(attr, 'is required')
          error_object.add(:base, error_object.full_message(attr, 'is required'))
        end
      end

      protected
        def attr_streamline(*args)
          opts = args.extract_options!
          unless opts.empty? or args.length == 1
            raise Streamline::FullUserClassError('Only provide one attribute at a time in api_attribute_map context')
          end
          streamline_attribute_list
          api_attribute_map
          args.each do |arg|
            if arg.is_a? Symbol
              define_attribute_method arg
              set_streamline_attribute arg
              if opts.has_key?(:as)
                set_api_attribute_map(arg, opts[:as])
              end
            end
          end
        end
    end

    def to_streamline_hash
      streamline_hash = { :secretKey => Rails.configuration.streamline[:user_info_secret] }
      @attributes.each_pair do |k,v|
        key = self.class.get_api_attribute_map(k.to_sym)
        streamline_hash[key] = v
      end
      streamline_hash
    end
  end
end
