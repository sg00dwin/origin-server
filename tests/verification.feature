@verify
Feature: Verification Tests

  Scenario: PHP creation tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type   |
      |     1     |   2   |  1   | php-5.3.2 |
    When the applications are created
    Then they should all be accessible

  Scenario: Rack creation tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   2   |  1   | rack-1.1.0 |
    When the applications are created
    Then they should all be accessible

  Scenario: WSGI creation tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   2   |  1   | wsgi-3.2.1 |
    When the applications are created
    Then they should all be accessible

  Scenario: PHP modification tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type   |
      |     1     |   2   |  1   | php-5.3.2 |
    When the applications are created
    Then they should all be accessible
    And they should be able to be changed

  Scenario: Rack modification tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   2   |  1   | rack-1.1.0 |
    When the applications are created
    Then they should all be accessible
    And they should be able to be changed

  Scenario: WSGI modification tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   2   |  1   | wsgi-3.2.1 |
    When the applications are created
    Then they should all be accessible
    And they should be able to be changed

  Scenario: Creation load tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type    |
      |     10    |   25  |  1   | php-5.3.2  |
      |     10    |   25  |  1   | rack-1.1.0 |
      |     10    |   25  |  1   | wsgi-3.2.1 |
    When the applications are created
    Then they should all be accessible
