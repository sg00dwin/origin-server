@sprint
Feature: Setup a new application

  Scenario:
    Given the libra client tools
    When 10 new customers are created
    And 5 applications of type 'php-5.3.2' are created per customer
    Then they should all be accessible
