def ask(message, secret = false)
  print message
  system "stty -echo" if secret
  STDIN.gets.chomp
ensure
  puts
  system "stty echo"
end

class String
  def self.random(len = 8)
    (0...len).map{65.+(rand(25)).chr}.join
  end
end
