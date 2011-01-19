@sprint1
Feature: Setup a new application

  Scenario:
    Given the libra client tools
    And 25 concurrent processes
    When 25 new users are created
    And 2 applications of type 'php-5.3.2' are created per user
    Then they should all be accessible
