@runtime
@runtime4
Feature: phpmoadmin Embedded Cartridge

  Scenario: Add remove phpmoadmin to one application
    Given a new php-5.3 type application
    
    When I embed a mongodb-2.0 cartridge into the application
    And I embed a phpmoadmin-1.0 cartridge into the application
    Then the embedded phpmoadmin-1.0 cartridge http proxy file will exist
    And 4 processes named httpd will be running
    And the embedded phpmoadmin-1.0 cartridge directory will exist
    And the embedded phpmoadmin-1.0 cartridge log files will exist
    And the embedded phpmoadmin-1.0 cartridge control script will exist

    When I stop the phpmoadmin-1.0 cartridge
    Then 2 processes named httpd will be running
    And the web console for the phpmoadmin-1.0 cartridge is not accessible

    When I start the phpmoadmin-1.0 cartridge
    Then 4 processes named httpd will be running
    And the web console for the phpmoadmin-1.0 cartridge is accessible
    
    When I restart the phpmoadmin-1.0 cartridge
    Then 4 processes named httpd will be running
    And the web console for the phpmoadmin-1.0 cartridge is accessible

    When I destroy the application
    Then 0 processes named httpd will be running
    And the embedded phpmoadmin-1.0 cartridge http proxy file will not exist
    And the embedded phpmoadmin-1.0 cartridge directory will not exist
    And the embedded phpmoadmin-1.0 cartridge log files will not exist
    And the embedded phpmoadmin-1.0 cartridge control script will not exist
