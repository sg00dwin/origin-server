Konacha.configure do |config|
  require 'ci/reporter/rspec'
  require 'capybara/poltergeist'

  config.spec_dir     = "test/js/"
  config.spec_matcher = /_spec\.|_test\./
  config.driver       = :poltergeist
  config.stylesheets  = %w(application)

  # Temp??
  WebMock.disable_net_connect!(:allow_localhost => true)
end if defined?(Konacha)
