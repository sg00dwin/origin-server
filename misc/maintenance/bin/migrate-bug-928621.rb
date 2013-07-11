#!/usr/bin/env oo-ruby

# Create GearDB from the existing gears on the node in a fast and
# efficient manner.  This should be run on every application serving
# node and is safe to re-run.

require 'rubygems'
require 'openshift-origin-node'
require 'openshift-origin-common'

gears = {}

OpenShift::Runtime::ApplicationContainer.all.each do |gear|
  begin
    env = OpenShift::Runtime::Utils::Environ.for_gear(gear.user.homedir)
    fqdn = env['OPENSHIFT_GEAR_DNS'].downcase
    container_name = env['OPENSHIFT_GEAR_NAME']
    namespace = env['OPENSHIFT_GEAR_DNS'].sub(/\..*$/,"").sub(/^.*\-/,"")
    gears[gear.uuid] = {'fqdn' => fqdn,  'container_name' => container_name, 'namespace' => namespace}
  rescue => e
    $stderr.puts("Bug 928612: collection FAILED: #{gear.uuid}: #{e}")
  end 
end

begin
  OpenShift::Runtime::GearDB.open(OpenShift::Runtime::GearDB::WRCREAT) do |d|
    gears.each do |uuid, dbent|
      d.store(uuid, dbent)
    end
  end
rescue => e
  $stderr.puts("Bug 928612: update FAILED!")
  exit(127)
end
exit(0)
