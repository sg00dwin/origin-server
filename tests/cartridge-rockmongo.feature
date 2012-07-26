@runtime
@runtime4
Feature: rockmongo Embedded Cartridge

  Scenario Outline: Add remove rockmongo to one application
    Given a new <type> type application
    
    When I embed a mongodb-2.0 cartridge into the application
    And I embed a rockmongo-1.1 cartridge into the application
    Then the embedded rockmongo-1.1 cartridge http proxy file will exist
    And 4 processes named httpd will be running
    And the embedded rockmongo-1.1 cartridge directory will exist
    And the embedded rockmongo-1.1 cartridge log files will exist
    And the embedded rockmongo-1.1 cartridge control script named rockmongo will exist

    When I stop the rockmongo-1.1 cartridge
    Then 2 processes named httpd will be running

    When I start the rockmongo-1.1 cartridge
    Then 4 processes named httpd will be running
    And the rockmongo web console url will be accessible
    
    When I restart the rockmongo-1.1 cartridge
    Then 4 processes named httpd will be running
    And the rockmongo web console url will be accessible

    When I destroy the application
    Then 0 processes named httpd will be running
    And the embedded rockmongo-1.1 cartridge http proxy file will not exist
    And the embedded rockmongo-1.1 cartridge directory will not exist
    And the embedded rockmongo-1.1 cartridge log files will not exist
    And the embedded rockmongo-1.1 cartridge control script named rockmongo will not exist

  Scenarios: Add Remove rockmongo to one Application Scenarios
    |type|
    |php-5.3|
