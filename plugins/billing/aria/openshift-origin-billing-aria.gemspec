# -*- encoding: utf-8 -*-
config_dir  = File.join(File.join("config", "**"), "*")
app_dir  = File.join(File.join("app", "**"), "*")
$:.push File.expand_path("../lib", __FILE__)
lib_dir  = File.join(File.join("lib", "**"), "*")
conf_dir  = File.join(File.join("lib", "**"), "*")
config_dir  = File.join(File.join("config", "**"), "*")
test_dir  = File.join(File.join("test", "**"), "*")
bin_dir  = File.join("bin", "*")

Gem::Specification.new do |s|
  s.name        = "openshift-origin-billing-aria"
  s.version     = /(Version: )(.*)/.match(File.read("rubygem-openshift-origin-billing-aria.spec"))[2].strip
  s.license     = 'ASL 2.0'
  s.authors     = ["Ravi Sankar Penta"]
  s.email       = ["p.ravisankar@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{OpenShift plugin for Aria Billing service}
  s.description = %q{Provides Aria Billing service based plugin}

  s.rubyforge_project = "openshift-origin-billing-aria"

  s.files       = Dir[lib_dir] + Dir[conf_dir] + Dir[config_dir] + Dir[app_dir]
  s.test_files  = Dir[test_dir]
  s.executables   = Dir[bin_dir]
  s.files       += %w(README.md Rakefile Gemfile rubygem-openshift-origin-billing-aria.spec openshift-origin-billing-aria.gemspec LICENSE COPYRIGHT)
  s.require_paths = ["lib"]

  s.add_dependency('openshift-origin-controller')
  s.add_dependency('pony')  
  s.add_dependency('json')  
  s.add_development_dependency('rake')  
  s.add_development_dependency('rspec')
  s.add_development_dependency('bundler')
  s.add_development_dependency('mocha')
end
