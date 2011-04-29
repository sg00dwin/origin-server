class VideoController < ApplicationController

  KNOWN_TITLES = {'openshiftmontage' => "Developers, ISVs, customers and partners", 
                  'flexproddemo' => "OpenShift Flex Product Tour",
                  'expressproddemo' => "OpenShift Express Product Tour"}

  def show
    @filename = params[:name]
    title = KNOWN_TITLES[@filename]
    @title = title ? title : @filename
  end

end
