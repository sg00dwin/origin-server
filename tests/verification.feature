@sprint
Feature: Verification Tests

  Scenario:
    Given the libra client tools
    And 1 concurrent processes
    And 1 new users
    When 1 applications of type 'php-5.3.2' are created per user
    Then they should all be accessible
    Then they should be able to be changed
