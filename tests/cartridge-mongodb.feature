@internals
Feature: MongoDB Application Sub-Cartridge
  
  Scenario Outline: Create one application with a MongoDB database
    Given an accepted node
    And a new guest account
    And a new <type> application
    When I configure a mongodb database
    Then the mongodb directory will exist
    And the mongodb configuration file will exist
    And the mongodb database will exist
    And the mongodb control script will exist
    And the mongodb daemon will be running
    And the mongodb admin user will have access

  Scenarios: Create Application With Database Scenarios
    |type|
    |php|
    

#  Scenario Outline: Delete one MongoDB Database from an Application
#    Given an accepted node
#    And a new guest account
#    And a new <type> application
#    And a new mongodb database
#    When I deconfigure the mongodb database
#    Then the mongodb daemon will not be running
#    And the mongodb database will not exist
#    And the mongodb control script will not exist
#    And the mongodb configuration file will not exist
#    And the mongodb directory will not exist
#
#  Scenarios: Delete one MongoDB database Scenarios
#    |type|
#    |php|
#
#    
  Scenario Outline: Start a MongoDB database
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And the mongodb daemon is stopped
    When I start the mongodb database
    Then the mongodb daemon will be running

  Scenarios: Start a MongoDB database scenarios
    |type|
    |php|
   

  Scenario Outline: Stop a MongoDB database
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And the mongodb daemon is running
    When I stop the mongodb database
    Then the mongodb daemon will not be running



  Scenarios: Stop a MongoDB database scenarios
    |type|
    |php|

  Scenario Outline: Restart a MongoDB database
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mongodb database
    And the mongodb daemon is running
    When I restart the mongodb database
    Then the mongodb daemon will be running
    And the mongodb daemon pid will be different

  Scenarios: Restart a MongoDB database scenarios
     |type|
     |php|

