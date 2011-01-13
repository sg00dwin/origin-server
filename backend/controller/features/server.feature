Feature: Setup a new application

  Scenario:
    Given at least one server
    When I try to find an available server
    Then I should get a result
