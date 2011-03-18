# Libra Node Limits

Feature: Limit User Resources

  # File Resources
  # - Quota: File count
  Scenario:
    Given a newly created user
    And a newly created application
    When he pushes 1000 files to the application
    Then the push should fail

  # - Quota: File count recovery
  Scenario:
    Given a newly created user
    And a newly created application
    And he adds 1000 files to the application
    And he pushes his application
    When he destroys his application
    And he purges 1000 files from the application
    And he pushes his application
    Then the push should succeed

  # - Quota: File capacity
  Scenario:
    Given a newly created user
    And a newly created application
    And he adds a 100mb file to the application
    When he pushes his application
    Then the push should fail

  # - Quota: File capacity recovery
  Scenario:
    Given a newly created user
    And a newly created application
    And he adds a 100mb file to the application
    And he pushes his application
    When he destroys his application
    And he purges the 100mb file from the application
    And he pushes his application
    Then the push should succeed

  # Process Resources
  # - fork bomb
  Scenario:
    Given a user
    And an appliction
    When he starts a fork-bomb on his application
    Then his application should not respond
    And he should have fewer than 51 processes

  # - fork bomb recovery
  Scenario:
    Given a user
    And an application
    And he starts a fork-bomb on his application
    When he restarts his application
    Then his application should respond

  # Network Resources

