@sprint
Feature: Verification Tests

  Scenario: PHP Creation tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type   |
      |     1     |   1   |  1   | php-5.3.2 |
      |     1     |  10   |  1   | php-5.3.2 |
      |     1     |   5   |  2   | php-5.3.2 |
    When the applications are created
    Then they should all be accessible
    Then they should be able to be changed
