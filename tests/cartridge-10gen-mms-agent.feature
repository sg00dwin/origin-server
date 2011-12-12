@internals
Feature: 10gen-mms-agent Embedded Cartridge

  Scenario Outline: Add 10gen-mms-agent to one application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a settings.py file exists
    When I configure 10gen-mms-agent
    Then the 10gen-mms-agent process will be running
    And the 10gen-mms-agent source directory will exist
    And the 10gen-mms-agent log directory will exist
    And the 10gen-mms-agent control script will exist

  Scenarios: Add 10gen-mms-agent to one Application Scenarios
    |type|
    |php|


  Scenario Outline: Remove 10gen-mms-agent from one Application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a settings.py file exists
    And a new 10gen-mms-agent
    When I deconfigure 10gen-mms-agent
    Then the 10gen-mms-agent process will not be running
    And the 10gen-mms-agent source directory will not exist
    And the 10gen-mms-agent log directory will not exist
    And the 10gen-mms-agent control script will not exist

  Scenarios: Remove 10gen-mms-agent from one Application Scenarios
    |type|
    |php|


  Scenario Outline: Start 10gen-mms-agent
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a settings.py file exists
    And a new 10gen-mms-agent
    And 10gen-mms-agent is stopped
    When I start 10gen-mms-agent
    Then the 10gen-mms-agent process will be running
    And the 10gen-mms-agent pid file will exist

  Scenarios: Start 10gen-mms-agent scenarios
    |type|
    |php|


  Scenario Outline: Stop 10gen-mms-agent
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a settings.py file exists
    And a new 10gen-mms-agent
    And 10gen-mms-agent is running
    When I stop 10gen-mms-agent
    Then the 10gen-mms-agent process will not be running    

  Scenarios: Stop 10gen-mms-agent scenarios
    |type|
    |php|


  Scenario Outline: Restart 10gen-mms-agent
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a settings.py file exists
    And a new 10gen-mms-agent
    And 10gen-mms-agent is running
    When I restart 10gen-mms-agent
    Then the 10gen-mms-agent process will be running
    And the 10gen-mms-agent pid file will exist

  Scenarios: Restart 10gen-mms-agent scenarios
    |type|
    |php|
