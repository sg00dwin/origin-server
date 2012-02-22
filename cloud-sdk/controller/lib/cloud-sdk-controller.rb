require "cloud-sdk-common"

module Cloud
  module Sdk
    module Controller
      require 'cloud-sdk-controller/engine/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
    end
  end
end

require "cloud-sdk-controller/app/models/application"
require "cloud-sdk-controller/app/models/cloud_user"
require "cloud-sdk-controller/app/models/legacy_reply"
require "cloud-sdk-controller/app/models/legacy_request"
require "cloud-sdk-controller/app/models/result_io"
require "cloud-sdk-controller/lib/cloud/sdk/application_container_proxy"
require "cloud-sdk-controller/lib/cloud/sdk/auth_service"
require "cloud-sdk-controller/lib/cloud/sdk/dns_service"
require "cloud-sdk-controller/lib/cloud/sdk/bind_dns_service"
require "cloud-sdk-controller/lib/cloud/sdk/data_store"
require "cloud-sdk-controller/lib/cloud/sdk/mongo_data_store"
