@internals
Feature: phpMoAdmin Embedded Cartridge

  Scenario Outline: Add phpMoAdmin to one application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    When I configure phpmoadmin
    Then a phpmoadmin http proxy file will exist
    And a phpmoadmin httpd will be running
    And the phpmoadmin directory will exist
    And phpmoadmin log files will exist
    And the phpmoadmin control script will exist

  Scenarios: Add phpMoAdmin to one Application Scenarios
    |type|
    |php|


  Scenario Outline: Remove phpMoAdmin from one Application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new phpmoadmin
    When I deconfigure phpmoadmin
    Then a phpmoadmin http proxy file will not exist
    And a phpmoadmin httpd will not be running
    And the phpmoadmin directory will not exist
    And phpmoadmin log files will not exist
    And the phpmoadmin control script will not exist

  Scenarios: Remove phpMoAdmin from one Application Scenarios
    |type|
    |php|


  Scenario Outline: Start phpMoAdmin
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new phpmoadmin
    And phpmoadmin is stopped
    When I start phpmoadmin
    Then a phpmoadmin httpd will be running

  Scenarios: Start phpMoAdmin scenarios
    |type|
    |php|


  Scenario Outline: Stop phpMoAdmin
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new phpmoadmin
    And phpmoadmin is running
    When I stop phpmoadmin
    Then a phpmoadmin httpd will not be running

  Scenarios: Stop phpMoAdmin scenarios
    |type|
    |php|


  Scenario Outline: Restart phpMoAdmin
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And a new phpmoadmin
    And phpmoadmin is running
    When I restart phpmoadmin
    Then a phpmoadmin httpd will be running

  Scenarios: Restart phpMoAdmin scenarios
    |type|
    |php|
