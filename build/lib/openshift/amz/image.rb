require 'aws'

module OpenShift
  module AWS
    class Image
      attr_accessor :conn, :amz_image_id, :name, :desc

      def log
        @@log
      end

      def self.find(conn, amz_image_id)
        image = Image.new(conn, nil, nil)
        image.amz_image_id = amz_image_id
        return image
      end

      def self.register(conn, instance_id, name, desc = "")
        log.info "Registering AMI based on instance (#{instance})..."
        image = Image.new(conn, name, desc)
        image.amz_image_id = conn.create_image(instance_id, name, desc)

        (0..30).each do
          break if get_value(:aws_state) == 'available'
          log.info "Image not available yet..."
          sleep 60
        end

        unless get_value(:aws_state) == 'available'
          raise "Operation Timed Out"
        end

        log.info "Done"

        return image
      end

      def initialize(conn, instance_id, name, desc = "")
        @conn, @name, @desc = conn, name, desc
      end

      def verify
        log.info "Tagging image (#{@amz_image_id}) as '#{VERIFIED_TAG}'..."
        conn.create_tag(@amz_image_id, 'Name', VERIFIED_TAG)
        puts "Done"
      end

      def get_value(key)
        @conn.describe_images([@amz_image_id], 'machine')[0][key]
      end
    end
  end
end
