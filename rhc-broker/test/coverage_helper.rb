# Must be the first module imported at entry points (executables that run
# in separate processes from the test harness) otherwise coverage will be
# incomplete

require 'simplecov'

SimpleCov.start 'rails' do
  coverage_dir 'test/coverage/'
  command_name ENV["TEST_NAME"] || 'rhc broker tests'
  add_group 'Online Extensions', 'lib/online'

  merge_timeout 10000
end