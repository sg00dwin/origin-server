#require 'rubygems'
#require 'rake'
#require 'rake/clean'
#require 'rake/testtask'

task :version, :version do |t, args|
  version = args[:version] || /(Version: )(.*)/.match(File.read("console.spec"))[2]
  raise "No version specified" unless version
  puts "RPM version  #{version}"
  major, minor, micro, *extra = version.split('.')
  puts "Ruby version #{major||0}.#{minor||0}.#{micro||0} #{extra.join('_')}"
  File::open('lib/console/version.rb', 'w') do |f|
    f << <<-VERSION_RB
module Console
  module VERSION #:nocov:
    MAJOR = #{major||0}
    MINOR = #{minor||0}
    MICRO = #{micro||0}
    #PRE  = '#{extra.join('_')}'
    STRING = [MAJOR,MINOR,MICRO].compact.join('.')
  end
end
    VERSION_RB
  end
end
