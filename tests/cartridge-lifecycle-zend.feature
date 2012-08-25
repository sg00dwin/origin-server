@runtime
@runtime_extended
@runtime_extended1
Feature: Cartridge Lifecycle Zend Verification Tests
  Scenario Outline: Application Creation
    Given the libra client tools
    And an accepted node
    When <app_count> <type> applications are created
    Then the applications should be accessible

  Scenarios: Application Creation Scenarios
    | app_count |     type     |
    |     1     |  zend-5.6     |
    
  Scenario Outline: Server Alias
    Given an existing <type> application
    When the application is aliased
    Then the application should respond to the alias

  Scenarios: Server Alias Scenarios
    |      type     |
    |   zend-5.6     |


  Scenario Outline: Application Stopping
    Given an existing <type> application
    When the application is stopped
    Then the application should not be accessible

  Scenarios: Application Stopping Scenarios
    |      type     |
    |   zend-5.6     |

  Scenario Outline: Application Starting
    Given an existing <type> application
    When the application is started
    Then the application should be accessible

  Scenarios: Application Starting Scenarios
    |      type     |
    |   zend-5.6     |
    
  Scenario Outline: Application Restarting
    Given an existing <type> application
    When the application is restarted
    Then the application should be accessible

  Scenarios: Application Restart Scenarios
    |      type     |
    |   zend-5.6     |
    
  Scenario Outline: Application Tidy
    Given an existing <type> application
    When I tidy the application
    Then the application should be accessible

  Scenarios: Application Tidy Scenarios
    |      type     |
    |   zend-5.6     |
    
  Scenario Outline: Application Snapshot
    Given an existing <type> application
    When I snapshot the application
    Then the application should be accessible
    When I restore the application
    Then the application should be accessible

  Scenarios: Application Snapshot Scenarios
    |      type     |
    |   zend-5.6     |

  Scenario Outline: Application Change Namespace
    Given an existing <type> application
    When the application namespace is updated
    Then the application should be accessible

  Scenarios: Application Change Namespace Scenarios
    |      type     |
    |   zend-5.6     |
    
  Scenario Outline: Application Destroying
    Given an existing <type> application
    When the application is destroyed
    Then the application should not be accessible

  Scenarios: Application Destroying Scenarios
    |      type     |
    |   zend-5.6     |
