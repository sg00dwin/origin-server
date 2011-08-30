

module Node

  class Cgroups

    def initialize(uuid, name)
      @uuid = uuid
      @name = name
    end

    def cgroup=(value)
      path = "/cgroup/all/libra/#{@uuid}/#{@name}"
      File::open(path, 'wb') { |f| f.write value.to_s.strip() }
    end

    def cgroup
      path = "/cgroup/all/libra/#{@uuid}/#{@name}"
      throw :cgroup_not_found unless File.exists?(path)
      fp = File.open(path)
      contents = ''
      fp.each {|line|
        contents << line
      }
      contents.strip()
    end
  end
end
