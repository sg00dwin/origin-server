@internals                                                                                                                                                                       
Feature: HAProxy Application Sub-Cartridge
  
  Scenario Outline: Create Delete one application with haproxy
    Given an accepted node
    And a new guest account
    And the guest account has no application installed
    And a new <type> application
    When I configure a php application
    When I configure haproxy
    Then the haproxy directory will exist
    And the haproxy configuration file will exist
    And the haproxy control script will exist
    And the haproxy daemon will be running
#    And the status-page will respond
    When I deconfigure haproxy
    Then the haproxy daemon will not be running
    And the haproxy control script will not exist
    And the haproxy configuration file will not exist
    And the haproxy directory will not exist

  Scenarios: Create Delete Application With Database Scenarios
    |type|
    |php|
    
#  Scenario Outline: Stop Start Restart a MySQL database
#    Given an accepted node
#    And a new guest account
#    And a new <type> application
#    And a new mysql database
#    And the mysql daemon is running
#    When I stop the mysql database
#    Then the mysql daemon will not be running
#    When I start the mysql database
#    Then the mysql daemon will be running
#    When I restart the mysql database
#    Then the mysql daemon will be running
#    And the mysql daemon pid will be different
#    And I deconfigure the mysql database
#
#  Scenarios: Stop Start Restart a MySQL database scenarios
#    |type|
#    |php|
