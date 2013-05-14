@runtime_extended2
@not-enterprise
Feature: Rockmongo Embedded Cartridge

  @rhel-only
  Scenario: Rockmongo Embedded Cartridge
    Given a v2 default node
    And a new mock-0.1 type application
    And I embed a mongodb-2.2 cartridge into the application
    And an agent settings.py file is created
    And I embed a rockmongo-1.1 cartridge into the application

    Then 2 process named httpd will be running
    And the embedded rockmongo-1.1 cartridge log files will exist

    When I stop the rockmongo-1.1 cartridge
    Then 0 processes named httpd will be running

    When I start the rockmongo-1.1 cartridge
    Then 2 processes named httpd will be running

    When I restart the rockmongo-1.1 cartridge
    Then 2 processes named httpd will be running

    When I destroy the application
    Then 0 processes named httpd will be running
    And the embedded rockmongo-1.1 cartridge log files will not exist
