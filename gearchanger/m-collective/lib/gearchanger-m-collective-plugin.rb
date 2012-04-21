require "stickshift-common"
require "gearchanger-m-collective-plugin/gearchanger/apptegic.rb"
require "gearchanger-m-collective-plugin/gearchanger/nurture.rb"
require "gearchanger-m-collective-plugin/gearchanger/mcollective_application_container_proxy.rb"
StickShift::ApplicationContainerProxy.provider=GearChanger::MCollectiveApplicationContainerProxy
