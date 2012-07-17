@runtime
@runtime1
@watchman
Feature: Watchman Service
  Scenario Outline: Watchman monitoring misc applications
    Given a Watchman object using "<log_file>" and "<epoch>"
    Then I should see "<restarts>" restarts

  Examples:
    | log_file     | epoch           | restarts |
    | messages.log | Feb  9 18:20:44 | 0 |
    | messages.log | Feb  7 18:20:44 | 2 |
    | messages.log | Feb  5 18:20:44 | 3 |
    | empty.log    | Jan  1 01:01:01 | 1 | 

  Scenario Outline:  Watchman monitoring JBoss application
    Given a JBoss application the Watchman Service using "<log_file>" and "<epoch>"
    Then I should see "<restarts>" restarts

  Examples:
    | log_file     | epoch           | restarts |
    | messages.log | Feb  9 18:00:00 | 0 |
    | messages.log | Feb  8 16:00:00 | 2 |
    | empty.log    | Feb  7 16:00:00 | 1 | 

  Scenario: Watchman survives one exception
    Given a Watchman object using "messages.log" and "Feb  7 18:20:44" expect "1" exception

  Scenario: Watchman dies with 5 exceptions
    Given a Watchman object using "messages.log" and "Feb  7 18:20:44" expect "5" exception
