# Must be the first module imported at entry points (executables that run
# in separate processes from the test harness) otherwise coverage will be
# incomplete

require 'simplecov'

COVERAGE_DIR = 'test/coverage/'
RESULT_SET = File.join(COVERAGE_DIR, '.resultset.json')

FileUtils.mkpath COVERAGE_DIR

SimpleCov.start 'rails' do
  coverage_dir COVERAGE_DIR
  command_name ENV["TEST_NAME"] || 'rhc broker tests'
  add_group 'Online Extensions', 'lib/online'

  merge_timeout 10000
end

FileUtils.touch(RESULT_SET)
FileUtils.chmod_R(01777, COVERAGE_DIR)