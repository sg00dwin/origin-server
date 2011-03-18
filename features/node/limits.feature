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
    And he purges 1000 files from the appliction
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


  # Network Resources

