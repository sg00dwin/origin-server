require 'logger'
require 'net/smtp'
require 'lib/openshift/constants'
require 'lib/openshift/ssh'
require 'lib/openshift/tito'
require 'lib/openshift/amz'

# Force synchronous stdout
STDOUT.sync, STDERR.sync = true

# Setup logger
@@log = Logger.new(STDOUT)
@@log.level = Logger::DEBUG

def log
  @@log
end

def exit_msg(msg)
  puts msg
  exit 0
end

def send_verified_email(image_id, image_name)
  msg = <<END_OF_MESSAGE   
From: Jenkins <noreply@redhat.com>
To: Libra Team <libra-express@redhat.com>
Subject: [Jenkins] DevEnv Image #{image_name} (#{image_id}) is QE Ready

Image #{image_name} (#{image_id}) has passed validation tests and is ready for QE.

END_OF_MESSAGE

  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message msg, "noreply@redhat.com", "libra-express@redhat.com"
  end
end
