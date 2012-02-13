load '/usr/bin/rhc-watchman'

Given /^a Watchman object using "([^"]*)" and "([^"]*)/ do |log, epoch|
  class Watchman
    attr_accessor :restarted
    def restart(uuid, env)
      @restarted = @restarted.nil? ? 1 : @restarted += 1
    end
  end

  home = File.expand_path("../misc/watchman", File.expand_path(File.dirname(__FILE__)))
  messages = "#{home}/#{log}"

  raise "Watchman tests missing #{messages} file" if not File.exist?(messages)

  @watchman = Watchman.new(messages, 2, false, DateTime.strptime(epoch, '%b %d %T'), home)
  @watchman.run
end

Then /^I should see "([^"]*)" restarts$/ do |restarts|
  @watchman.restarted == restarts
end
