@internals
Feature: Watchman Service
  Scenario Outline: Watchman not run as daemon
    Given a Watchman object using "<log_file>" and "<epoch>"
    Then I should see "<restarts>" restarts

  Examples:
    | log_file     | epoch           | restarts |
    | messages.log | Feb  9 18:20:44 | 0 |
    | messages.log | Feb  7 18:20:44 | 1 |
    | messages.log | Feb  5 18:20:44 | 2 |
    | empty.log    | Jan  1 01:01:01 | 0 | 
