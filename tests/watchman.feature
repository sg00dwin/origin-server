@internals @watchman
Feature: Watchman Service
  Scenario Outline: Watchman monitoring misc applications
    Given a Watchman object using "<log_file>" and "<epoch>"
    Then I should see "<restarts>" restarts

  Examples:
    | log_file     | epoch           | restarts |
    | messages.log | Feb  9 18:20:44 | 1 |
    | messages.log | Feb  7 18:20:44 | 2 |
    | messages.log | Feb  5 18:20:44 | 3 |
    | empty.log    | Jan  1 01:01:01 | 1 | 

  Scenario Outline:  Watchman monitoring JBoss application
    Given a JBoss application the Watchman Service using "<log_file>" and "<epoch>" at "<timestamp>"
    Then I should see "<restarts>" restarts

  # timestamp only used to get date, time pulled from server.log 17:55:00
  Examples:
    | log_file     | epoch           | timestamp      | restarts |
    | messages.log | Feb  9 18:00:00 | Feb 9 00:00:00 | 0 |
    | messages.log | Feb  9 16:00:00 | Feb 9 00:00:00 | 1 |
    | empty.log    | Feb  9 16:00:00 | Feb 9 00:00:00 | 1 | 
