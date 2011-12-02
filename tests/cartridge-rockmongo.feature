@internals
Feature: rockmongo Embedded Cartridge

  Scenario Outline: Add rockmongo to one application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    When I configure rockmongo
    Then a rockmongo http proxy file will exist
    And a rockmongo httpd will be running
    And the rockmongo directory will exist
    And rockmongo log files will exist
    And the rockmongo control script will exist

  Scenarios: Add rockmongo to one Application Scenarios
    |type|
    |php|


  Scenario Outline: Remove rockmongo from one Application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new rockmongo
    When I deconfigure rockmongo
    Then a rockmongo http proxy file will not exist
    And a rockmongo httpd will not be running
    And the rockmongo directory will not exist
    And rockmongo log files will not exist
    And the rockmongo control script will not exist

  Scenarios: Remove rockmongo from one Application Scenarios
    |type|
    |php|


  Scenario Outline: Start rockmongo
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new rockmongo
    And rockmongo is stopped
    When I start rockmongo
    Then a rockmongo httpd will be running

  Scenarios: Start rockmongo scenarios
    |type|
    |php|


  Scenario Outline: Stop rockmongo
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new rockmongo
    And rockmongo is running
    When I stop rockmongo
    Then a rockmongo httpd will not be running

  Scenarios: Stop rockmongo scenarios
    |type|
    |php|


  Scenario Outline: Restart rockmongo
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new rockmongo
    And rockmongo is running
    When I restart rockmongo
    Then a rockmongo httpd will be running

  Scenarios: Restart rockmongo scenarios
    |type|
    |php|
