@verify
Feature: Verification Tests

  Scenario: PHP modification tests
    Given the libra client tools
    And an accepted node
    And the following test data
      | processes | users | apps |    type   |
      |     1     |   1   |  1   | php-5.3.2 |
    When the applications are created
    Then they should all be accessible
    And they should be able to be changed

  Scenario: Rack modification tests
    Given the libra client tools
    And an accepted node
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   1   |  1   | rack-1.1.0 |
    When the applications are created
    Then they should all be accessible
    And they should be able to be changed

  Scenario: WSGI modification tests
    Given the libra client tools
    And an accepted node
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   1   |  1   | wsgi-3.2.1 |
    When the applications are created
    Then they should all be accessible
    And they should be able to be changed

  Scenario: Creation load tests
    Given the libra client tools
    And an accepted node
    And a 300 second command timeout
    And a 60 second http request timeout
    And the following test data
      | processes | users | apps |    type    |
      |     10    |   10  |  1   | php-5.3.2  |
    When the applications are created
    Then they should all be accessible

  Scenario: Website tests
    Given the following website links
      |         uri          |  protocol  |
      | /                    |    https   |
      | /app                 |    https   |
      | /app/getting_started |    https   |
      | /app/user/new        |    https   |
    When they are accessed
    Then no errors should be thrown

