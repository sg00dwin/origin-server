# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
lib_dir  = File.join(File.join("lib", "**"), "*")
test_dir  = File.join(File.join("test", "**"), "*")
bin_dir  = File.join("bin", "*")

Gem::Specification.new do |s|
  s.name        = "cloud-sdk-controller"
  s.version     = /(Version: )(.*)/.match(File.read("cloud-sdk-controller.spec"))[2].strip
  s.license     = 'ASL 2.0'
  s.authors     = ["Krishna Raman"]
  s.email       = ["kraman@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Cloud Sdk Controller Rails Engine}
  s.description = %q{Cloud Sdk Controller Rails Engine}

  s.rubyforge_project = "cloud-sdk-controller"

  s.files       = Dir[lib_dir]
  s.test_files  = Dir[test_dir]
  s.executables   = Dir[bin_dir]
  s.files       += %w(README.md Rakefile Gemfile cloud-sdk-controller.spec cloud-sdk-controller.gemspec LICENSE COPYRIGHT)
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_dependency "json"
  s.add_dependency "cloud-sdk-common"
  s.add_dependency('state_machine')  
  s.add_dependency('open4')
  s.add_development_dependency('rake')  
  s.add_development_dependency('rspec')
  s.add_development_dependency('bundler')
  s.add_development_dependency('mocha')
end