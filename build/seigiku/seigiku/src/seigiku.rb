#!/usr/bin/ruby

require 'rubygems'
require 'open3'
require 'logger'
require 'pathname'
require 'pp'
require 'json'
require 'artifact_hash'
require 'specfile'
require 'set'

#log_file = File.open('/tmp/seigiku.log', File::WRONLY | File::CREAT | File::TRUNC)
$logger = Logger.new('/tmp/seigiku.log')
$brew_url = "https://brewweb.devel.redhat.com/buildinfo?buildID=%d"
$koji_url = "http://koji.fedoraproject.org/koji/buildinfo?buildID=%d"

# RHEL-6.2-build
$brew_tags = %w{f11-import-s390x-build it-eng-rhel-6-build cloud-ruby-rhel-6-candidate rhel-6-libra-build libra-rhel-6.2-build libra-rhel-6.2-candidate libra-maven-rhel-6.2-candidate}
$koji_tags = %w{f16-build f16-updates-testing}

##
# Tool for processing RPM spec files, reconciling Brew against the Koji build system and producing a trac wiki table of results
class Seigiku
  attr_accessor :koji_artifacts, :brew_artifacts, :black_list
  # [seed_file] contains packages that are 1 level removed dependencies or require attribution
  # e.g. stated dependency is libjpeg-devel a seed for libjpeg would be explicitly required
  # [black_file] contains the black listed specfiles
  def initialize(seed_file, black_file)
    $logger.info("Starting Seigiku processing")

    seeds = JSON.parse(File.read(seed_file))

    @brew_artifacts = BrewArtifactHash.new($brew_tags, seeds)
    @koji_artifacts = KojiArtifactHash.new($koji_tags, seeds)

    @black_list = JSON.parse(File.read(black_file))
  end

  # anchor provides starting point for spec file search
  # All spec files found recursively from this directory will be processed for inclusion on the web page
  def start(anchor)
    specfiles = []
    Dir["#{anchor}/**/*.spec"].each {|f|
      if ! @black_list['specfiles'].include?(File.basename(f))
        specfiles << process_specfile(f)
      end
    }

#    specfiles.each {|f|
#      print_specfile_table(f)
#    }
    
    specfiles
  end

  def print_rpm_table(specfiles)
    puts <<-"HEADER"
      
==== RPM Usage ====

||= **Name** =||= **Brew** =||= **Koji** =||= **Note** =||    
    HEADER

    rpms = SortedSet.new
    specfiles.each {|spec| rpms.merge(spec['requires'])}
    
    rpms.each {|rpm|
      puts "|| {{{#{rpm}}}} || {{{#{@brew_artifacts[rpm]['build_name']}}}} || {{{#{@koji_artifacts[rpm]['build_name']}}}} || #{@koji_artifacts[rpm].note} ||" 
    }
  end
  
  def bold_italic(word)
    "**//#{word}//**"
  end

  # Read specfile - cache artifacts.
  def process_specfile(input)
    specfile = Specfile.new(input)

    specfile['requires'].each {|rpm|
      @brew_artifacts[rpm]
      @koji_artifacts[rpm]
    }

    specfile
  end

  # Produce wiki table for each spec file
  def print_specfile_table(specfile)
    puts <<-"HEADER"

==== RPM #{specfile['name']} ====
||= **Name**      =|| #{specfile['name']} ||= **Specfile** =|||| #{File.basename(specfile['filesystem_name'])} ||
||= **Summary**   =|||||||| #{specfile['summary']} ||
||= **License**   =|| #{specfile['license']} ||= **Version**  =|||| #{specfile['version']} ||
||= **Provides**  =|||||||| #{specfile['provides'].join(', ')} ||
||= **Brew Tags** =|||||||| #{$brew_tags.reverse.join(' > ')} ||
||= **Koji Tags** =|||||||| #{$koji_tags.reverse.join(' > ')} ||
    
  HEADER

    puts "||= **Requires** =||= **Review** =||= **Brew** =||= **Koji** =||= **Note** =||"
    specfile['requires'].sort.each {|rpm|
      review_needed = ''
      if @brew_artifacts[rpm]['build_name'] && @koji_artifacts[rpm]['build_name']
        brew_nrv = @brew_artifacts[rpm]['build_name'].scan(/^(.+)\.(.+)$/)[0]
        koji_nrv = @koji_artifacts[rpm]['build_name'].scan(/^(.+)\.(.+)$/)[0]
        review_needed = brew_nrv[0] == koji_nrv[0] ? '' : 'X'
      else
        review_needed = 'X'
      end

      brew_cell = @brew_artifacts[rpm].to_url
      brew_cell = brew_cell ? "[#{brew_cell} #{@brew_artifacts[rpm]['build_name']}]": ""

      koji_cell = @koji_artifacts[rpm].to_url
      koji_cell = koji_cell ? "[#{koji_cell} #{@koji_artifacts[rpm]['build_name']}]": ""

      puts "|| {{{#{rpm}}}} || #{review_needed} || #{brew_cell} || #{koji_cell} || #{@koji_artifacts[rpm].note} ||"
    }
    puts "|||||||||| **Last Updated** #{Time.new.inspect}||"
  end


end

home_dir = '/home/jhonce/Projects/li.0203/'
specfiles = []
prg = Seigiku.new(home_dir + "build/seigiku/seed_list.json", home_dir + "build/seigiku/black_list.json")
specfiles.concat(prg.start(home_dir))
#specfiles.concat(prg.start('/home/jhonce/Projects/li/build/seigiku'))
specfiles.concat(prg.start("/home/jhonce/Projects/rhc"))

specfiles.sort.each {|s|
  prg.print_specfile_table(s)
}

prg.print_rpm_table(specfiles)

puts "\n * Black list of spec files: " + prg.black_list['specfiles'].join(", ")
