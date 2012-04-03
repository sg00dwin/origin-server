require 'rubygems'
require 'open3'
require 'logger'
require 'pp'

##
# Container to cache spec file information
# provides two synthetic keys:
# [requires] array of all requires keywords from spec file
# [provides] array of all provides and name keywords from spec file
#
# Known Issues:
# * url and description keys are worthless given the simple parsing used
# * description values are stored as keys. See above.
class Specfile < Hash
  FORMAT_QUERY = 'rpm --specfile %s -q --queryformat '
  REQUIRES_QUERY = FORMAT_QUERY + "'[%%{requires} ]'"
  PROVIDES_QUERY = FORMAT_QUERY + "'[%%{provides} ]'"
  NAME_QUERY = FORMAT_QUERY + "'[%%{name} ]'"
  INFO_QUERY = 'rpm --specfile %s -q --info'
  # spec_file is full path to spec file
  def initialize(spec_file)
    store('filesystem_name', spec_file)
    store('requires', [])
    requires = read_from_command(REQUIRES_QUERY % spec_file)
    requires.each {|e| store('requires', e.split.uniq) }

    # treat as aliases for our purposes
    provides = read_from_command(PROVIDES_QUERY % spec_file)

    # pull all possible names
    names = read_from_command(NAME_QUERY % spec_file)

    aliases = []
    (names | provides).each {|e|
      aliases << e.split
    }
    store('provides', aliases.uniq)

    # info will be union of all fields found.
    info = read_from_command(INFO_QUERY % spec_file)
    info.each { |l|
      fields = l.split(':')
      begin
        k = fields[0].strip.downcase
        v = fields[1]
        if ! has_key?(k)
          store(k, v)
        end
      rescue Exception => e
        $stderr.puts "processing of field #{fields.inspect} from #{spec_file}: #{e.inspect}"  
      end
    }
  end

  def <=>(o)
    return case
      when self['name'].nil? && ! o['name'].nil?
        1
      when ! self['name'].nil? && o['name'].nil?
        -1
      when self['name'].nil? && o['name'].nil?
        0
      else
        self['name'] <=> o['name']
      end
  end

  private

  def read_from_command(command)
    output = []
    Open3.popen3(command) {|stdin, stdout, stderr, thr_wait|
      stdout.each {|l|
        output << l.strip
      }

      stderr.each {|l|
        $logger.warn(l.strip)
      }
    }
    output
  end
end
