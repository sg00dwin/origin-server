#!/bin/env ruby
# This generates a yaml based fact list

require 'facter'
require 'yaml'

puts YAML.dump(Facter.to_hash)
