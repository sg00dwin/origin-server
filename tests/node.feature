@internals
@internals1
@node
Feature: Account Management
  Scenario: Create One Account
    Given an accepted node
    When I create a guest account
    Then an account password entry should exist
    And an account PAM limits file should exist
    #And an HTTP proxy config file should exist
    And an account cgroup directory should exist
    And a traffic control entry should exist
    And an account home directory should exist
    And selinux labels on the account home directory should be correct
    And disk quotas on the account home directory should be correct

  Scenario: Delete One Account
    Given an accepted node
    And a new guest account
    When I delete the guest account
    Then an account password entry should not exist
    And an account PAM limits file should not exist
    And a traffic control entry should not exist
    And an account cgroup directory should not exist
    And an account home directory should not exist
    
 Scenario: Delete One Namespace
    Given an accepted node
    When I create a new namespace
    And I delete the namespace
    Then a namespace should get deleted
