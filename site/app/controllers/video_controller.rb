class VideoController < ApplicationController

  KNOWN_TITLES = {'OpenShift-Ecosystem' => "Developers, ISVs, customers and partners", 
                  'OpenShift-Flex-demo' => "OpenShift Flex Product Tour",
                  'OpenShift-Express-demo' => "OpenShift Express Product Tour",
                  'OpenShift-Appcelerator-demo' => "Deploying Mobile Apps on OpenShift with Appcelerator", 
                  'OpenShift-eXo-demo' => 'Deploying to OpenShift PaaS with the eXo cloud IDE'}

  def show
    @filename = params[:name]
    title = KNOWN_TITLES[@filename]
    @title = title ? title : @filename
  end

end
