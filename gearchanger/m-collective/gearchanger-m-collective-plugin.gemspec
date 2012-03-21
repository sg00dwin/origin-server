# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
lib_dir  = File.join(File.join("lib", "**"), "*")
test_dir  = File.join(File.join("test", "**"), "*")
bin_dir  = File.join("bin", "*")

Gem::Specification.new do |s|
  s.name        = "gearchanger-m-collective-plugin"
  s.version     = /(Version: )(.*)/.match(File.read("gearchanger-m-collective-plugin.spec"))[2].strip
  s.license     = 'ASL 2.0'
  s.authors     = ["Krishna Raman"]
  s.email       = ["kraman@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Gearchanger plugin for managing nodes/gears over m-collective}
  s.description = %q{Provides a m-collective based plugin to manage nodes/gears}

  s.rubyforge_project = "gearchanger-m-collective-plugin"

  s.files       = Dir[lib_dir]
  s.test_files  = Dir[test_dir]
  s.executables   = Dir[bin_dir]
  s.files       += %w(README.md Rakefile Gemfile gearchanger-m-collective-plugin.spec gearchanger-m-collective-plugin.gemspec LICENSE COPYRIGHT)
  s.require_paths = ["lib"]

  s.add_dependency('stickshift-controller')
  s.add_dependency('json')  
  s.add_development_dependency('rake')  
  s.add_development_dependency('rspec')
  s.add_development_dependency('bundler')
  s.add_development_dependency('mocha')
end
