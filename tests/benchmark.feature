@benchmark
Feature: Application Benchmark Tests
  Scenario Outline: Application Creation
    Given the libra client tools
    And an accepted node
    Then benchmark creating <type> applications 10 times
    And finally cleanup all applications that the benchmark created

  Scenarios: Application Scenarios
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  jenkins-1.4 |
    |  diy-0.1     |

  Scenario: Generate Application Creation Benchmark Report
    Given an accepted node
    Then generate the application creation benchmark report


#  Scenario Outline: Monotonically Create Applications
#    Given the libra client tools
#    And an accepted node
#    Then benchmark creating <type> applications monotonically with 10 samples
#    And finally cleanup all applications that the benchmark created
#
#  Scenarios: Application Scenarios
#    |     type     |
#    |  php-5.3     |
#    |  ruby-1.8    |
#    |  python-2.6  |
#    |  perl-5.10   |
#    |  jbossas-7   |
#    |  nodejs-0.6  |
#    |  jenkins-1.4 |
#    |  diy-0.1     |

#  Scenario: Generate Monotonically Creating Applications Benchmark Report
#    Given an accepted node
#    Then generate the monotonically creating applications benchmark report


  Scenario Outline: Scaled Application Creation
    Given the libra client tools
    And an accepted node
    Then benchmark creating scaled <type> applications with <num> gears 10 times
    And finally cleanup all applications that the benchmark created

  Scenarios: Application Scenarios
    |     type     |   num   |
    |  php-5.3     |   1     |
    |  php-5.3     |   4     |
    |  ruby-1.8    |   1     |
    |  python-2.6  |   1     |
    |  perl-5.10   |   1     |
    |  jbossas-7   |   1     |
    |  jbossas-7   |   2     |
    |  jbossas-7   |   3     |
    |  jbossas-7   |   4     |
    |  nodejs-0.6  |   1     |

  Scenario: Generate Scaled Application Creation Benchmark Report
    Given an accepted node
    Then generate the scaled application creation benchmark report


