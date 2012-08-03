@runtime
@runtime4
Feature: Trap User Shell

  As a system designer
  I should be able to limit user login to a defined set of commands
  So that I can ensure the security of the system

  Scenario: Command Running
    Given a new client created php-5.3 application
    Then I can run "ls / > /dev/null" with exit code: 0
    And I can run "this_should_fail" with exit code: 127
    And I can run "true" with exit code: 0
    And I can run "java -version" with exit code: 0
    And I can run "scp" with exit code: 1
    And I can get the rhcsh splash
    And I can get the rhcsh help
    When the application is destroyed
    Then the application should not be accessible

  Scenario: Tail Logs
    Given a new client created php-5.3 application
    #And the user has no tail processes running 
    And the user has no tail process running
    And a running SSH log stream
    And the user has 1 tail process running in 5 seconds
    When I terminate the SSH log stream
    #Then there will be no tail processes running in 5 seconds
    Then the user has no tail processes running in 5 seconds
    When the application is destroyed
    Then the application should not be accessible

  Scenario: Access Quota
    Given a new client created php-5.3 application
    Then I can obtain disk quota information via SSH
    When the application is destroyed
    Then the application should not be accessible

