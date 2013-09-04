# This file is used by Rack-based servers to start the application.
ENV["ENABLE_NR_MONITORING"] = "true"
require ::File.expand_path('../config/environment',  __FILE__)
run Broker::Application
