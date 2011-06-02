module OpenShift
  module AWS
    def send_verified_email(amz_image_id)
      msg = <<END_OF_MESSAGE
From: Jenkins <noreply@redhat.com>
To: Matt Hicks <mhicks@redhat.com>
Subject: DevEnv Image #{amz_image_id} QE Ready

Image #{amz_image_id} is ready for QE.
END_OF_MESSAGE

      Net::SMTP.start('localhost') do |smtp|
        smtp.send_message msg, "noreply@redhat.com", "mhicks@redhat.com"
      end
    end
  end
end
