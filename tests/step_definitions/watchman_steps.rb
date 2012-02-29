load 'li-test/node/scripts/bin/rhc-watchman'

Given /^a Watchman object using "([^"]*)" and "([^"]*)"$/ do |log, epoch|
  class Watchman1 < Watchman
    attr_accessor :restarted
    def restart(uuid, env)
      @restarted = @restarted.nil? ? 1 : @restarted += 1
    end

    def now() DateTime.new(2012, 02, 14, 18, 55, 00, 0, "+05:00") end
  end

  home = File.expand_path("../misc/watchman", File.expand_path(File.dirname(__FILE__)))
  messages = "#{home}/#{log}"

  raise "Watchman tests missing #{messages} file" if not File.exist?(messages)

  @watchman = Watchman1.new(messages, 2, false, DateTime.strptime(epoch, '%b %d %T'), home)
  @watchman.run
end

Then /^I should see "([^"]*)" restarts$/ do |restarts|
  count = @watchman.restarted.nil? ? 0: @watchman.restarted
  count.should be restarts.to_i
end

Given /^a JBoss application the Watchman Service using "([^"]*)" and "([^"]*)"$/ do |log, epoch |

  home = File.expand_path("../misc/watchman", File.expand_path(File.dirname(__FILE__)))
  messages = "#{home}/#{log}"

  raise "Watchman tests missing #{messages} file" if not File.exist?(messages)

  @watchman = Watchman1.new(messages, 2, false, DateTime.strptime(epoch, '%b %d %T'), home)
  @watchman.run
end

Given /^a Watchman object using "([^"]*)" and "([^"]*)" expect "([^"]*)" exceptions*$/ do |log, epoch, exceptions|
  class Watchman3 < Watchman
    attr_accessor :restarted
    def restart(uuid, env)
      @restarted = @restarted.nil? ? 1 : @restarted += 1
      raise "expected exception"
    end

    def now() DateTime.new(2012, 02, 14, 18, 55, 00, 0, "+05:00") end
  end

  home = File.expand_path("../misc/watchman", File.expand_path(File.dirname(__FILE__)))
  messages = "#{home}/#{log}"

  raise "Watchman tests missing #{messages} file" if not File.exist?(messages)

  @watchman = Watchman3.new(messages, 2, false, DateTime.strptime(epoch, '%b %d %T'), home)

  iterations = exceptions.to_i
  iterations.times do
    begin
      @watchman.run
    rescue
      #puts "exception in steps... #{@watchman.retries}"
      # eat exceptions since we are not running as a daemon they all show up here...
    end
  end

  expected = 10 - iterations
  @watchman.retries.should be expected
end
