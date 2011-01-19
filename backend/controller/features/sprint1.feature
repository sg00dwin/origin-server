@sprint1
Feature: Setup a new application

  Scenario:
    Given the libra client tools
    And 10 concurrent processes
    When 20 new users are created
    And 10 applications of type 'php-5.3.2' are created per user
    Then they should all be accessible
