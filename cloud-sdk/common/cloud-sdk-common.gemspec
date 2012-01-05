# OS independent path locations
lib_dir  = File.join(File.join("lib", "**"), "*")
test_dir  = File.join(File.join("test", "**"), "*")

Gem::Specification.new do |s|
  s.name        = "cloud-sdk-common"
  s.version     = /(Version: )(.*)/.match(File.read("cloud-sdk-common.spec"))[2].strip
  s.authors     = ["Krishna Raman"]
  s.email       = ["kraman@gmail.com"]
  s.homepage    = "http://www.openshift.com"
  s.summary     = %q{Cloud Development Common}
  s.description = %q{Cloud Development Common}

  s.rubyforge_project = "cloud-sdk-common"
  s.files       = Dir[lib_dir] + Dir[test_dir]
  s.files       += %w(README.md Rakefile Gemfile cloud-sdk-common.spec cloud-sdk-common.gemspec)
  s.require_paths = ["lib"]

  s.add_dependency("json", "1.4.3")
  s.add_dependency("activemodel", "3.0.10")
end
