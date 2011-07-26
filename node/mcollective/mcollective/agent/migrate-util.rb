require 'open4'

module LibraMigration
  
  def self.replace_in_file(file, old_value, new_value, sep=',')
    output, exitcode = execute_script("sed -i \"s#{sep}#{old_value}#{sep}#{new_value}#{sep}g\" #{file} 2>&1")
    #TODO handle exitcode
    return "Updated '#{file}' changed '#{old_value}' to '#{new_value}'.  output: #{output}  exitcode: #{exitcode}\n"
  end

  def self.execute_script(cmd)
    pid, stdin, stdout, stderr = Open4::popen4(cmd)
    stdin.close
    ignored, status = Process::waitpid2 pid
    exitcode = status.exitstatus
    output = ''
    begin
      Timeout::timeout(5) do
        while (line = stdout.gets)
          output << line
        end
      end
    rescue Timeout::Error
      Log.instance.debug("execute_script WARNING - stdout read timed out")
    end
    return output, exitcode
  end
end