def ask(message, secret = false)
  print message
  system "stty -echo" if secret
  STDIN.gets.chomp
ensure
  puts
  system "stty echo"
end

def logfile(name = 'log')
  dir = 'log'
  Dir.mkdir dir unless File.directory?(dir)

  tries = 0
  logfile = (
    begin
      file = File.join(
        dir,
        "%s%s.log" % [name,(tries > 0 ? ".#{tries}" : '')]
      )
      throw if File.exists?(file)
      file
    rescue
      tries += 1
      if tries < 10
        retry
      else
        exit
      end
    end
  )
  logfile
end
