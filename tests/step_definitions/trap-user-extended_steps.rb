def ssh_command(command) 
  "ssh -o BatchMode=yes -o StrictHostKeyChecking=no -q -t #{@gear.uuid}@#{@app.name}-#{@account.domain}.dev.rhcloud.com " + command
end

When /^I (start|stop) the application using ctl_all via rhcsh$/ do |action|
  cmd = case action
  when 'start'
    ssh_command("rhcsh ctl_all start")
  when 'stop'
    ssh_command("rhcsh ctl_all stop")
  end

  $logger.debug "Running #{cmd}"

  output = `#{cmd}`

  $logger.debug "Output: #{output}"
end