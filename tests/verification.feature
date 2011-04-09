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
    And a 300 second command timeout
    And a 120 second http request timeout
    And the following test data
      | processes | users | apps |    type    |
      |     3     |   25  |  1   | php-5.3.2  |
      |     3     |   25  |  1   | rack-1.1.0 |
      |     3     |   25  |  1   | wsgi-3.2.1 |
    When the applications are created
    Then they should all be accessible

  Scenario: Website tests
    Given the following website links
      |         uri          |  protocol  |
      | /                    |    https   |
      | /app                 |    https   |
      | /app/getting_started |    https   |
      | /app/users           |    https   |
    When they are accessed
    Then no errors should be thrown

