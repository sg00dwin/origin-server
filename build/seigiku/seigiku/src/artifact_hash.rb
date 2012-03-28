require 'rubygems'
require 'pathname'
require 'json'

##
# Container providing a read-through cache for build results. Indexed on rpm name
# Note: read misses cause syncronous http query to configured build system, execution times will reflect network access times.
class ArtifactHash < Hash
  LATEST_PKG = "%s --quiet latest-pkg %s '%s'"
  BUILD_INFO = "%s --quiet buildinfo '%s'"
  
  private
  alias :super_store :store
  
  public
  # [command] is the unix command to query the Koji-based system
  # [url_prototype] should contain one  %d substitution anchor which will be replaced with the build_id when to_url is called on an entry
  # [tags] array of the Koji tags used to query for build results
  # [seeds] array of hashes containing the seed rpms to provide information that cannot be provided via queries
  def initialize(command, url_prototype, tags, seeds)
    if ! defined?(Struct::Artifact)
      Struct.new("Artifact", :name, :build_id, :build_name, :build_system, :url_prototype, :note) {
        def to_url
          build_id ? url_prototype % build_id: nil
        end
      }
    end
    @tags = tags
    @command = command
    @url_prototype = url_prototype
    
    @seeds = seeds
    @seeds.each {|s| self[s['name']] }
  end

  def [](key)
    has_key?(key) ? super(key): populate(key)
  end

  private

  def populate(key)
    build_id = build = nil
    provides = []
    query_key =  key.include?('(') ?  key.sub(/(.*)\((.*)\)/, '\1-\2') : key
    @tags.each {|t|
      exec = LATEST_PKG % [@command, t, query_key]
      pkg = `#{exec}`.strip.squeeze(' ')
      $logger.debug("#{exec} => <#{pkg}>") if not pkg.empty?
      if pkg && ! pkg.empty?
        fields = pkg.split
        build = fields[0]
        exec = BUILD_INFO % [@command, build]
        build_info = `#{exec}`

        rpm_parsing = false
        [*build_info].each {|l|
          l.strip!
          if build_match =  l.match(/^BUILD: .* \[(\d+)\].*/)
            build_id = build_match[1]
          elsif  rpm_parsing
            basename = File.basename(l)
            nvra = basename.scan(/^(.+)-(.+)-(.+)\.(.+).rpm$/)[0]
            provides << nvra[0]
          elsif l.match(/^RPMs:$/)
            rpm_parsing = true
          end
        }
      end
    }

    artifact = Struct::Artifact.new(key, build_id, build, @command, @url_prototype, find_note(query_key))
    super_store(key, artifact)
    provides.uniq.each {|rpm|
      a = Struct::Artifact.new(rpm, build_id, build, @command, @url_prototype, find_note(rpm))
      super_store(rpm, a)
    }

    return artifact
  end

  def find_note(key)
    query = @seeds.find {|item| item['name'] == key}
    query ? query['note']: nil
  end
end

##
# Specialized container for caching Koji build system results
class KojiArtifactHash < ArtifactHash
  def initialize(tags, seeds = [])
    super('koji', 'http://koji.fedoraproject.org/koji/buildinfo?buildID=%d', tags, seeds)
  end
end

##
# Specialed container for caching Brew build system results
class BrewArtifactHash < ArtifactHash
  def initialize(tags, seeds = [])
    super('brew', 'https://brewweb.devel.redhat.com/buildinfo?buildID=%d', tags, seeds)
  end
end
