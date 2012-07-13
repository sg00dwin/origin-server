#
# Configure rcov analysis of tests
# Derived from http://www.betaful.com/2010/11/rails-3-rcov-test-coverage/
#

require 'fileutils'

namespace :coverage do

  task :clean do
    rm_rf "test/coverage"
    FileUtils.mkdir "test/coverage"
    Rcov = "rcov --rails -Ilib \
                 --text-summary -x '/usr/lib/ruby' \
                 -i 'site'"
  end

  desc 'Coverage analysis of unit tests'
  task :units => :clean do
    options = ["--html",      "test/unit/*_test.rb",
               "--output",    "test/coverage/unit/",
               "--aggregate", "test/coverage/unit_coverage.data"]
    system("#{Rcov} #{options.join(' ')}")
  end

  desc 'Coverage analysis of functional tests'
  task :functionals => :clean do
    options = ["--html",      "test/functional/*_test.rb",
               "--output",    "test/coverage/functional/",
               "--aggregate", "test/coverage/funtional_coverage.data"]
    system("#{Rcov} #{options.join(' ')}")
  end

  desc 'Coverage analysis of integration tests'
  task :integrations => :clean do
    options = ["--html",      "test/integration/*_test.rb",
               "--output",    "test/coverage/integration/",
               "--aggregate", "test/coverage/integration_coverage.data"]
    system("#{Rcov} #{options.join(' ')}")
  end

  desc 'Coverage analysis of all tests'
  task :all => :clean do
    Rake::Task["coverage:units"].invoke
    Rake::Task["coverage:functionals"].invoke
    Rake::Task["coverage:integrations"].invoke
  end

end
 
task :coverage do
  Rake::Task["coverage:all"].invoke
end
