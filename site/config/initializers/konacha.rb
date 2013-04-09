Konacha.configure do |config|
  require 'ci/reporter/rspec'
  require 'capybara/poltergeist'

  config.spec_dir     = "test/js/"
  config.spec_matcher = /_spec\.|_test\./
  config.driver       = :poltergeist
  config.stylesheets  = %w(application)
end if defined?(Konacha)
