@benchmark
Feature: Application Benchmark Tests
  Scenario Outline: Application Creation
    Given the libra client tools
    And an accepted node
    Then benchmark creating <type> applications 50 times
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


  Scenario Outline: Monotonically Create Applications
    Given the libra client tools
    And an accepted node
    Then benchmark creating <type> applications monotonically with 20 samples
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

  Scenario: Generate Monotonically Creating Applications Benchmark Report
    Given an accepted node
    Then generate the monotonically creating applications benchmark report

