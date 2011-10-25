@internals
Feature: metrics Embedded Cartridge

  Scenario Outline: Add metrics to one application
    Given an accepted node
    And a new guest account
    And a new <type> application
    When I configure metrics
    Then a metrics http proxy file will exist
    And a metrics httpd will be running
    And the metrics directory will exist
    And metrics log files will exist
    And the metrics control script will exist

  Scenarios: Add Metrics to one Application Scenarios
    |type|
    |php|


  Scenario Outline: Remove Metrics from one Application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new metrics
    When I deconfigure metrics
    Then a metrics http proxy file will not exist
    And a metrics httpd will not be running
    And the metrics directory will not exist
    And metrics log files will not exist
    And the metrics control script will not exist

  Scenarios: Remove Metrics from one Application Scenarios
    |type|
    |php|


  Scenario Outline: Start Metrics
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new metrics
    And metrics is stopped
    When I start metrics
    Then a metrics httpd will be running

  Scenarios: Start Metrics scenarios
    |type|
    |php|


  Scenario Outline: Stop Metrics
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new metrics
    And metrics is running
    When I stop metrics
    Then a metrics httpd will not be running

  Scenarios: Stop Metrics scenarios
    |type|
    |php|


  Scenario Outline: Restart Metrics
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new metrics
    And metrics is running
    When I restart metrics
    Then a metrics httpd will be running

  Scenarios: Restart Metrics scenarios
    |type|
    |php|
