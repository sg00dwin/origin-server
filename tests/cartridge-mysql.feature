@internals
Feature: MySQL Application Sub-Cartridge
  
  Scenario: Create one PHP Application with a MySQL Database
    Given an accepted node
    And a new guest account
    And the guest account has no application installed
    And a new PHP application
    When I configure a MySQL database
    Then the MySQL directory will exist # with sub directories
    And the MySQL configuration will exist # 
    And the MySQL database will exist

    And the MySQL control script will exist # check owner, permissions, label
    And the MySQL daemon will be running
    And the admin user will have access
    
  Scenario: Delete one MySQL Database from a PHP Application
    Given an accepted node
    And a new guest account
    And a new PHP application
    And a MySQL database
    When I deconfigure the MySQL database
    Then the MySQL daemon will be stopped
    And the MySQL database will not exist
    And the MySQL control script will not exist
    And the MySQL configuration file will not exist
    And the MySQL directory will not exist


  Scenario: Start a MySQL database
    Given an accepted node
    And a new guest account
    And a new PHP application
    And a new MySQL database
    And the MySQL database is stopped
    When I start the MySQL database

  Scenario: Stop a MySQL database
    Given an accepted node
    And a new guest account
    And a new PHP application
    And a new MySQL database
    And the MySQL database is running
    When I stop the MySQL database
