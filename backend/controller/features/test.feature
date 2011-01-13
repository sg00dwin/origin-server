Feature: Setup a new application

  Scenario:
    Given an existing 'mhicks' user
    When I try to create a 'mhicks' user
    Then I should get an exception
