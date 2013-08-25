# Must be the first module imported at entry points (executables that run
# in separate processes from the test harness) otherwise coverage will be
# incomplete

require 'simplecov'

SimpleCov.adapters.delete(:root_filter)
SimpleCov.filters.clear

class EngineFilter < SimpleCov::Filter
  def initialize(names)
    @names = names
  end
  def matches?(source_file)
    engines.each do |root_path|
      return false if source_file.filename.start_with? root_path
    end
    return true
  end
  def engines
    @engines ||= begin
      engines = Rails.application.railties.engines.select{ |e| @names.include? e.class.to_s }
      engines.map { |e| e.config.root.to_s } << Rails.application.config.root.to_s
    end
  end
end

COVERAGE_DIR = 'test/coverage/'
RESULT_SET = File.join(COVERAGE_DIR, '.resultset.json')

FileUtils.mkpath COVERAGE_DIR

SimpleCov.start 'rails' do
  coverage_dir COVERAGE_DIR
  command_name (SimpleCov::CommandGuesser.original_run_command || 'Site tests').strip

  add_filter EngineFilter.new('Console::Engine')

  # Filters - these files will be ignored.
  add_filter 'app/controllers/styleguide_controller.rb'

  use_merging
  merge_timeout 1000

  # Groups - general categories of test areas
  #add_group('Controllers') { |src_file| src_file.filename.include?(File.join(%w[lib rhc commands])) }
  #add_group('REST API')    { |src_file| src_file.filename.include?(File.join(%w[lib rhc])) }
  #add_group('REST')        { |src_file| src_file.filename.include?(File.join(%w[lib rhc/rest])) }  
  #add_group('Legacy')      { |src_file| src_file.filename.include?(File.join(%w[bin])) or
  #                                      src_file.filename.include?(File.join(%w[lib rhc-common.rb])) }
  #add_group('Test')        { |src_file| src_file.filename.include?(File.join(%w[features])) or
  #                                      src_file.filename.include?(File.join(%w[spec])) }

  # Note, the #:nocov: coverage exclusion  should only be used on external functions 
  #  that cannot be nondestructively tested in a developer environment.
end

FileUtils.touch(RESULT_SET)
FileUtils.chmod_R(01777, COVERAGE_DIR)
