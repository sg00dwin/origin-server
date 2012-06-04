def ask(message, secret = false)
  print message
  system "stty -echo" if secret
  STDIN.gets.chomp
ensure
  puts
  system "stty echo"
end

def login(password = nil)
  @client ||= (
    libra_server = get_var('libra_server')
    rhlogin = get_var('default_rhlogin')
    password = ask("Password: ",true) unless password

    end_point = "https://#{libra_server}/broker/rest/api"
    Rhc::Rest::Client.new(end_point, rhlogin, password)
  )
end

class Array
  def filter(items = [],invert = false)
    # Allow us to pass in anything that can test for include
    unless items.respond_to?(:include?)
      items = [items].compact
    end
    retval = find_all do |x|
      if items.empty?
        block_given? ? (yield x) : x
      else
        items.include?(block_given? ? (yield x) : x)
      end
    end
    invert ? self - retval : retval
  end
end

class String
  def self.random(len = 8)
    (0...len).map{65.+(rand(25)).chr}.join
  end
end
