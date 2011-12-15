# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
lib_dir  = File.join(File.join("lib", "**"), "*")
test_dir  = File.join(File.join("test", "**"), "*")
bin_dir  = File.join("bin", "*")
require 'cloud-sdk-controller/version'

Gem::Specification.new do |s|
  s.name        = "cloud-sdk-controller"
  s.version     = Cloud::Sdk::Controller::VERSION
  s.authors     = ["Krishna Raman"]
  s.email       = ["kraman@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Cloud Sdk Controller Rails Engine}
  s.description = %q{Cloud Sdk Controller Rails Engine}

  s.rubyforge_project = "cloud-sdk-controller"

  s.files       = Dir[lib_dir]
  s.test_files  = Dir[test_dir]
  s.executables   = Dir[bin_dir]
  s.files       += %w(README.md Rakefile Gemfile cloud-sdk-controller.spec cloud-sdk-controller.gemspec)
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", "~> 3.0.10"
  s.add_dependency "json", "1.4.3"
  s.add_dependency "cloud-sdk-common", "= #{s.version}"
end
