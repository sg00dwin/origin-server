Feature: Setup a new application

  Scenario:
    Given an existing 'mhicks' user
    When I create a 'mhicks' user
    Then I should get an exception

  Scenario:
    Given a newly created user
    When I look up that user
    Then he should have no servers
    And he should have no applications

  Scenario:
    Given a newly created user
    When I modify and update the user
    Then the changes are saved
