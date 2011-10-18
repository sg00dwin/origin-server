require 'open4'

module LibraMigration
  module Util
    def self.append_to_file(f, value)
      file = File.open(f, 'a')
      begin
        file.puts ""
        file.puts value
      ensure
        file.close
      end
      return "Appended '#{value}' to '#{file}'"
    end
    
    def self.contains_value?(f, value)
      file = File.open(f, 'r')
      begin
        file.each {|line| return true if line.include? value}
      ensure
        file.close
      end
      false
    end
    
    def self.replace_in_file(file, old_value, new_value, sep=',')
      output, exitcode = execute_script("sed -i \"s#{sep}#{old_value}#{sep}#{new_value}#{sep}g\" #{file} 2>&1")
      #TODO handle exitcode
      return "Updated '#{file}' changed '#{old_value}' to '#{new_value}'.  output: #{output}  exitcode: #{exitcode}\n"
    end
    
    def self.get_env_var_value(app_home, env_var_name)
      file_contents = file_to_string("#{app_home}/.env/#{env_var_name}").chomp
      eq_index = file_contents.index('=')
      value = file_contents[(eq_index + 1)..-1]
      value = value[1..-1] if value.start_with?("'")
      value = value[0..-2] if value.end_with?("'")
      return value
    end
    
    def self.file_to_string(file_path)
      file = File.open(file_path, "r")
      str = nil
      begin
        str = file.read
      ensure
        file.close
      end
      return str
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
end