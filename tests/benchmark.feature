@benchmark
Feature: Application Benchmark Tests
  Scenario: Accepted Node
    Given the libra client tools
    And an accepted node

  Scenario Outline: Application Creation
    Then benchmark creating <type> applications 10 times
    And finally cleanup all applications that the benchmark created

  Scenarios: Application Scenarios
    |     type     |
    |  php-5.3     |
    |  jbossas-7   |

  Scenario: Generate Application Creation Benchmark Report
    Given an accepted node
    Then generate the application creation benchmark report

  Scenario Outline: Scaled Application Creation
    Then benchmark creating scaled <type> applications with <num> gears 10 times
    And finally cleanup all applications that the benchmark created

  Scenarios: Application Scenarios
    |     type     |   num   |
    |  php-5.3     |   1     |
    |  php-5.3     |   4     |
    |  jbossas-7   |   1     |
    |  jbossas-7   |   4     |

  Scenario: Generate Scaled Application Creation Benchmark Report
    Given an accepted node
    Then generate the scaled application creation benchmark report


