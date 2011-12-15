require 'cloud-sdk-controller'
require 'rails'

module Cloud
  module Sdk
    class CloudEngine < Rails::Engine
      paths.app.controllers      << "lib/cloud-sdk-controller/app/controllers"
      paths.app.models           << "lib/cloud-sdk-controller/app/models"
      paths.lib                  << "lib/cloud-sdk-controller/lib"
      paths.config               << "lib/cloud-sdk-controller/config"
      config.autoload_paths      += %W(#{config.root}/lib)
    end
  end
end
