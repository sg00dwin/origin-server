load File.dirname(__FILE__) + '/../../node/scripts/bin/rhc-watchman'

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

  @watchman = Watchman1.new(messages, 0, false, DateTime.strptime(epoch, '%b %d %T'), home)
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

  @watchman = Watchman1.new(messages, 0, false, DateTime.strptime(epoch, '%b %d %T'), home)
  @watchman.run
end

Given /^a Watchman object using "([^"]*)" and "([^"]*)" expect "([^"]*)" exceptions*$/ do |log, epoch, exceptions|
  class ExpectedException < Exception
  end

  class Watchman3 < Watchman
    attr_accessor :restarted
    def restart(uuid, env)
      @restarted = @restarted.nil? ? 1 : @restarted += 1
      raise ExpectedException
    end

    def now() DateTime.new(2012, 02, 14, 18, 55, 00, 0, "+05:00") end
  end

  home = File.expand_path("../misc/watchman", File.expand_path(File.dirname(__FILE__)))
  messages = "#{home}/#{log}"

  raise "Watchman tests missing #{messages} file" if not File.exist?(messages)

  iterations = exceptions.to_i
  @watchman = Watchman3.new(messages, 0, false, DateTime.strptime(epoch, '%b %d %T'), home, 5)

  iterations.times do
    begin
      @watchman.run
    rescue ExpectedException
      #puts "exception in steps... #{@watchman.retries}"
      # eat exceptions since we are not running as a daemon they all show up here...
    end
  end

  expected = 5 - iterations
  @watchman.retries.should be expected
end
