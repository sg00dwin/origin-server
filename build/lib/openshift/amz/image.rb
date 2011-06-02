require 'aws'

module OpenShift
  module AWS
    class Image
      attr_accessor :conn, :amz_id, :name

      def log
        @@log
      end

      def initialize(conn, instance_id, name, desc = "")
        log.info "Registering AMI based on instance (#{instance})..."

        @conn, @name, @desc = conn, name, desc
        @amz_id = @conn.create_image(instance_id, name, desc)

        (0..30).each do
          break if get_value(:aws_state) == 'available'
          log.info "Image not available yet..."
          sleep 60
        end

        unless get_value(:aws_state) == 'available'
          raise "Operation Timed Out"
        end

        log.info "Done"
      end

      def get_value(key)
        @conn.describe_images([@amz_id], 'machine')[0][key]
      end
    end
  end
end
