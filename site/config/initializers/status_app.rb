STATUS_APP_ROOT = File.join(File.expand_path(Rails.configuration.root), 'app','subsites','status')
STATUS_APP_HOSTS = YAML.load(File.open(File.join(STATUS_APP_ROOT,'config','hosts.yml')))
require 'status_app'
