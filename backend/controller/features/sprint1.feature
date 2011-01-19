@sprint1
Feature: Setup a new application

  Scenario:
    Given the libra client tools
    When 1000 new users are created
    And 5 applications of type 'php-5.3.2' are created per user
    Then they should all be accessible
