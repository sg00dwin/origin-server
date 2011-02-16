@sprint
Feature: Setup a new application

  Scenario:
    Given the libra client tools
    And 10 concurrent processes
    And 10 new users
    When 1 applications of type 'php-5.3.2' are created per user
    Then they should all be accessible
    Then they should be able to be changed
