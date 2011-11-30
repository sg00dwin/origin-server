# OS independent path locations
bin_dir  = File.join("bin", "*")
conf_dir = File.join("conf", "*")
lib_dir  = File.join(File.join("lib", "**"), "*")
test_dir  = File.join(File.join("test", "**"), "*")

Gem::Specification.new do |s|
  s.name        = "cloud-sdk-controller"
  s.version     = /(Version: )(.*)/.match(File.read("cloud-sdk-controller.spec"))[2]
  s.authors     = ["Krishna Raman"]
  s.email       = ["kraman@gmail.com"]
  s.homepage    = "http://www.openshift.com"
  s.summary     = %q{Cloud Development Controller}
  s.description = %q{Cloud Development Controller}

  s.rubyforge_project = "cloud-sdk-controller"
  s.files       = Dir[lib_dir] + Dir[bin_dir] + Dir[conf_dir] + Dir[test_dir]
  s.files       += %w(README.md Rakefile Gemfile cloud-sdk-controller.spec cloud-sdk-controller.gemspec)
  s.executables = Dir[bin_dir].map {|binary| File.basename(binary)}
  s.require_paths = ["lib"]
  
  s.add_dependency("rails", "3.1.3")
  s.add_dependency("rack")
  s.add_dependency("json")
  s.add_dependency("stomp")
  s.add_dependency("parseconfig")
  s.add_dependency("xml-simple")
  s.add_dependency("multimap")
  s.add_dependency("regin")  

  s.add_dependency("highline", "1.5.1")
  s.add_dependency("state_machine", "1.0.2")
#  s.add_dependency("cloud-sdk-common")

  s.add_development_dependency("sass-rails", "~> 3.1.5")
  s.add_development_dependency("coffee-rails", "~> 3.1.1")
  s.add_development_dependency("uglifier", ">= 1.0.3")
  s.add_development_dependency("jquery-rails")
  s.add_development_dependency('cucumber', ">= 0.9.0")
  s.add_development_dependency('rspec')
  s.add_development_dependency('mocha', "0.9.8")
  s.add_development_dependency('ruby-debug')
  s.add_development_dependency('rake', ">= 0.8.7")
end