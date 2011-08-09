@internals
Feature: Trap User Shell

  As a system designer
  I should be able to limit user login to a defined set of commands
  So that I can ensure the security of the system

  Scenario: Tail Logs
    Given an end user
    And the user creates a new php-5.3 application
    And the user has no tail processes running 
    And a running SSH log stream
    And the user has 1 tail process running in 5 seconds
    When I terminate the SSH log stream
    Then there will be no tail processes running in 5 seconds
    
    
