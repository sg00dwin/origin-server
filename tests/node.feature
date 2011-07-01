@internals
Feature: Account Management
#
# Account control (li-controller) cartridge
#
# configure
  Scenario: Create One Account
    Given an accepted node
#    And the following test data
#     | accountname                      | ssh_key_name | ssh_pub_key |
#     | 00112233445566778899aabbccdde000 | testkeyname0 | testkey0    |
    When I create a guest account
    Then an account password entry should exist
    And an account PAM limits file should exist
    #And an HTTP proxy config file should exist
    And an account cgroup directory should exist
    And a traffic control entry should exist
    And an account home directory should exist
    #And the account home directory permissions should be correct
    And selinux labels on the account home directory should be correct
    And disk quotas on the account home directory should be correct
    And the account should have an SSH key with the correct label
    

# deconfigure
  Scenario: Delete One Account
    Given an accepted node
#    And the following test data
#     | accountname                      | ssh_key_name | ssh_pub_key |
#     | 00112233445566778899aabbccdde001 | testkeyname1 | testkey1    |
    And a new guest account
    When I delete the guest account
    Then an account password entry should not exist
    And an account PAM limits file should not exist
    And a traffic control entry should not exist
    And an account cgroup directory should not exist
    And an account home directory should not exist
    
