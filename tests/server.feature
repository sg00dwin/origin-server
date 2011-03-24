Feature: Setup a new application

  Scenario:
    Given at least one server
    When I find an available server
    Then I should get a result

  Scenario:
    Given an available server
    And a newly created user
    When I create a 'test' app for 'php-5.3.2'
    Then the user should have the app on one server
