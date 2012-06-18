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

def returning(value)
  yield(value)
  value
end

def deep_sort(object, deep = false)
  # from http://seb.box.re/2010/1/15/deep-hash-ordering-with-ruby-1-8/
  if object.is_a?(Hash)
    # Hash is ordered in Ruby 1.9!
    res = returning(RUBY_VERSION >= '1.9' ? Hash.new : ActiveSupport::OrderedHash.new) do |map|
      object.each {|k, v| map[k] = deep ? convert_hash_to_ordered_hash_and_sort(v, deep) : v }
    end
    return res.class[res.sort {|a, b| a[0].to_s <=> b[0].to_s } ]
  elsif deep && object.is_a?(Array)
    array = Array.new
    object.each_with_index {|v, i| array[i] = convert_hash_to_ordered_hash_and_sort(v, deep) }
    return array
  else
    return object
  end
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
