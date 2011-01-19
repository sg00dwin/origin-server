@sprint1
Feature: Setup a new application

  Scenario:
    Given the libra client tools
    And 1 concurrent processes
    When 1 new users are created
    And 1 applications of type 'php-5.3.2' are created per user
    Then they should all be accessible
