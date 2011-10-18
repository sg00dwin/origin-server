require 'logger'
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
