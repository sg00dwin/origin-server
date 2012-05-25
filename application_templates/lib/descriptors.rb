#!/usr/bin/env ruby
$: << 'lib'

require 'rubygems'
require 'rhc-common'
require 'rhc-rest'
require 'yaml'
require 'json'
require 'highline/import'

class Hash
  def method_missing(method, *params)
    method = method.to_sym
    return self[method] if self.keys.collect(&:to_sym).include?(method)
    super
  end
end

class Symbol
  def to_proc(*args)
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end

def my_log(message)
  print "#{message}..."
  x = yield
  puts "done"
  x
end

def destroy_app(app)
  my_log("Destroying application #{app.name}..."){
    app.destroy
  }
end

def login
  @client ||= (
    libra_server = get_var('libra_server')
    rhlogin = get_var('default_rhlogin')
    password = ask("Password:  ") { |q| q.echo = "*" }

    end_point = "https://#{libra_server}/broker/rest/api"
    Rhc::Rest::Client.new(end_point, rhlogin, password)
  )
end

def targets
  @targets ||= YAML.load_file(TARGETS)
end

def template_function(name)
  # Shortcut to making filename
  def newfile(name,type) "#{name}.#{type}" end

  # Parameters to pass to script
  parameters = {
    :command => 'add',
    :descriptor => newfile(name,'yaml'),
    :metadata => newfile(name,'json')
  }

  # Parameters from our targets.yml file
  info = YAML.load_file(target_for(name))
  parameters[:named] = info[:display_name]
  parameters[:cost] = info[:cost]
  parameters[:tags] = (info[:tags] || []).map{|x| x.to_s}.join(',')

  # Parameters from metadata
  File.open(metadata_for(name)) do |f|
    metadata = JSON.parse(f.read)
    parameters['git-url'] = metadata['git']
  end

  template_command(parameters)
end

def template_command(params)
  cmd = "rhc-admin-ctl-template"
  params.each do |key,val|
    cmd << " --%s '%s'" % [key,val.to_s]
  end
  cmd
end

def create_files(dir,name,opts)
  dir = File.join(dir,name.to_s)
  FileUtils.remove_entry_secure dir if File.directory?(dir)
  Dir.mkdir dir

  {:json => opts[:metadata], :yaml => opts[:descriptor]}.each do |ext,val|
    file = File.join(dir,"#{name}.#{ext}")
    File.open(file,'w') do |f|
      f.puts val
    end
  end
end

def templates_dir
  dir = 'templates'
  Dir.mkdir dir unless File.directory?(dir)
  dir
end

def applications
  Dir.glob("#{templates_dir}/*/").map{|x| x.split('/').last}
end

def descriptor_for(app)
  File.join(dir_for(app),"descriptor.yaml")
end

def descriptor_exists?(app)
  File.exists?(descriptor_for(app))
end

def metadata_for(app)
  File.join(dir_for(app),"metadata.json")
end

def target_for(app)
  File.join(dir_for(app),'target.yml')
end

def deploy_script_for(app)
  File.join(dir_for(app),"create.sh")
end

def dir_for(app)
  dir = File.join(templates_dir,app)
  Dir.mkdir unless File.directory?(dir)
  dir
end
