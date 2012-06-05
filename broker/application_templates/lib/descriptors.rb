#!/usr/bin/env ruby

require 'rubygems'
require 'rhc-common'
require 'rhc-rest'
require 'yaml'
require 'json'

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

def targets
  @targets ||= YAML.load_file(TARGETS)
end

def templates_dir
  dir = 'templates'
  Dir.mkdir dir unless File.directory?(dir)
  dir
end

def application_templates
  names = Dir.glob("#{templates_dir}/*/").map{|x| x.split('/').last}
  names.map{|x| ApplicationTemplate.new(x)}
end

def template_command(params)
  cmd = "rhc-admin-ctl-template"
  params.each do |key,val|
    cmd << " --%s '%s'" % [key,val.to_s]
  end
  cmd
end

def deploy_script
  File.expand_path(
    File.join(templates_dir,"deploy.rb")
  )
end

class ApplicationTemplate
  attr_accessor :name, :dir

  def initialize(name)
    @name = name
    @dir = dir_for(@name)
  end

  def target(relative = false)
    file_for(:target,relative)
  end

  def descriptor(relative = false)
    file_for(:descriptor, relative)
  end

  def metadata(relative = false)
    file_for(:metadata, relative)
  end

  def script(relative = false)
    file_for(:script, relative)
  end

  def save(type,data,relative = false)
    file = file_for(type,relative)
    mode = (type == :script ? 0644 : 0755)
    File.open(file,'w',mode) do |f|
      f.write data
    end
  end

  def file_for(type,relative = false)
    filename = case type
               when :target
                 'target.yml'
               when :descriptor
                 'descriptor.yaml'
               when :metadata
                 'metadata.json'
               when :script
                 'create.sh'
               else
                 return nil
               end
    if relative
      filename
    else
      File.expand_path(File.join(@dir,filename))
    end
  end

  def template_opts(files = true, relative = true)
    # Parameters to pass to script
    parameters = {
      :command => 'add',
    }

    # Don't include files for when we're creating the devenv script
    if files
      parameters.merge!({
        :descriptor => descriptor(relative),
        :metadata => metadata(relative)
      })
    end

    # Parameters from our targets.yml file
    info = YAML.load_file(target)
    parameters.merge!({
      :named => info[:display_name],
      :cost => info[:cost],
      :tags => (info[:tags] || []).map{|x| x.to_s}.join(','),
      'git-url' => info[:metadata][:git_url]
    })

    parameters
  end

  def template_function(files = true, relative = true)
    parameters = template_opts(files,relative)
    template_command(parameters)
  end

  private
  def dir_for(app)
    dir = File.join(templates_dir,app)
    Dir.mkdir unless File.directory?(dir)
    dir
  end
end
