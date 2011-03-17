Feature: Setup a new application

  Scenario:
    Given at least one server
    When I find an available server
    Then I should get a result

  Scenario:
    Given a newly created user
    And an available server
    When I create a 'test' app for 'php-5.3.2'
    Then the user should have the app on one server
