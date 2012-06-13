require 'sprint'
require 'report'
require 'reports'

require 'yaml'
require 'pry'

CONFIG_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'../config')
CAL_PATH='https://mail.corp.redhat.com/home/shadowman@redhat.com/OpenShift.ics'

# Read Rally configuration file
rally_config = YAML.load_file(File.join(CONFIG_DIR,'rally.yml'))

# Define available report types
reports_config = YAML.load_file(File.join(CONFIG_DIR,'reports.yml'))
$report_types = {}
reports_config.each do |name,args|
  $report_types[name] = UserStoryReport.new(args)
end

$sprint = Sprint.new({
  :calendar => CAL_PATH,
  :rally_config => rally_config
})

dev = Report.new({
  :reports => [:no_tasks,:blocked,:not_approved,:rejected],
  :summary_email => 'libra-devel@redhat.com'
})

qe = Report.new({
  :reports => [:not_qe_ready,:rejected],
  :summary_email => 'libra-qe@redhat.com',
  :nag_owners => false
})

# Run reports from here. See README for more information
# For example:
#   dev.send_email('jpoelstra@redhat.com',false)

binding.pry
