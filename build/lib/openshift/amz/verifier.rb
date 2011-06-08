require 'net/smtp'

module OpenShift
  module AWS
    def send_verified_email(amz_image_id, amz_image_name)
      msg = <<END_OF_MESSAGE
From: Jenkins <noreply@redhat.com>
To: Libra Team <libra-express@redhat.com>
Subject: DevEnv Image #{amz_image_name} (#{amz_image_id}) is QE Ready

Image #{amz_image_name} (#{amz_image_id}) has passed validation tests and is ready for QE.

END_OF_MESSAGE

      Net::SMTP.start('localhost') do |smtp|
        smtp.send_message msg, "noreply@redhat.com", "libra-express@redhat.com"
      end
    end
  end
end
