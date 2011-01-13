Feature: Setup a new application

  Scenario:
    Given an existing 'mhicks' user
    When I try to create a 'mhicks' user
    Then I should get an exception

  Scenario:
    Given a newly created user
    When I look up that user
    Then he should have no servers
    And he should have no applications
