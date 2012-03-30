@internals
@node
Feature: rockmongo Embedded Cartridge

  Scenario Outline: Add remove rockmongo to one application
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
    When I deconfigure rockmongo
    Then a rockmongo http proxy file will not exist
    And a rockmongo httpd will not be running
    And the rockmongo directory will not exist
    And rockmongo log files will not exist
    And the rockmongo control script will not exist
    And I deconfigure the mongodb database

  Scenarios: Add Remove rockmongo to one Application Scenarios
    |type|
    |php|

  Scenario Outline: Stop Start Restart rockmongo
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new rockmongo
    And rockmongo is running
    When I stop rockmongo
    Then a rockmongo httpd will not be running
    When I start rockmongo
    Then a rockmongo httpd will be running
    When I restart rockmongo
    Then a rockmongo httpd will be running
    And I deconfigure rockmongo
    And I deconfigure the mongodb database

  Scenarios: Stop Start Restart rockmongo scenarios
    |type|
    |php|
