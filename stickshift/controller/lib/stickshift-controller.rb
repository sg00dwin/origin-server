require "stickshift-common"

module StickShift
  module Controller
    require 'stickshift-controller/engine/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  end
end

require "stickshift-controller/app/models/application"
require "stickshift-controller/app/models/cloud_user"
require "stickshift-controller/app/models/legacy_reply"
require "stickshift-controller/app/models/legacy_request"
require "stickshift-controller/app/models/result_io"
require "stickshift-controller/lib/cloud/sdk/application_container_proxy"
require "stickshift-controller/lib/cloud/sdk/auth_service"
require "stickshift-controller/lib/cloud/sdk/dns_service"
require "stickshift-controller/lib/cloud/sdk/bind_dns_service"
require "stickshift-controller/lib/cloud/sdk/data_store"
require "stickshift-controller/lib/cloud/sdk/mongo_data_store"
