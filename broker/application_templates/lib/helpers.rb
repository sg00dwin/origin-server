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
  File.join(dir,"#{name}.log")
end
