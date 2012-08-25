@runtime
@runtime4
Feature: metrics Embedded Cartridge

  Scenario: CRUD metrics embedded cartridge 
    Given a new perl-5.10 type application
    
    When I embed a metrics-0.1 cartridge into the application
    Then the embedded metrics-0.1 cartridge http proxy file will exist
    And 4 processes named httpd will be running
    And the embedded metrics-0.1 cartridge directory will exist
    And the embedded metrics-0.1 cartridge log files will exist
    And the embedded metrics-0.1 cartridge control script will exist

    When I stop the metrics-0.1 cartridge
    Then 2 processes named httpd will be running
    And the web console for the metrics-0.1 cartridge is not accessible

    When I start the metrics-0.1 cartridge
    Then 4 processes named httpd will be running
    And the web console for the metrics-0.1 cartridge is accessible
    
    When I restart the metrics-0.1 cartridge
    Then 4 processes named httpd will be running
    And the web console for the metrics-0.1 cartridge is accessible

    When I destroy the application
    Then 0 processes named httpd will be running
    And the embedded metrics-0.1 cartridge http proxy file will not exist
    And the embedded metrics-0.1 cartridge directory will not exist
    And the embedded metrics-0.1 cartridge log files will not exist
    And the embedded metrics-0.1 cartridge control script will not exist
