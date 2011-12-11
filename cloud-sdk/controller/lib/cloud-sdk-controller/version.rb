module Cloud
  module Sdk
    module Controller
      VERSION = File.open("#{File.dirname(__FILE__)}/../../cloud-sdk-controller.spec").readlines.delete_if{ |x| !x.match(/Version:/) }.first.split(':')[1].strip
    end
  end
end
