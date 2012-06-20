@singleton
Feature: Idler

  # runcon -u ?? -r system_r -t libra_initrc_t

  Scenario: Idle one PHP Application
    Given an accepted node
    And a new guest account
    And a new php_idler application
    And the php application is running
    And record the active capacity
    When I idle the php application
    Then the php application will not be running
    And the active capacity has been reduced
    And the php application health-check will be successful

#  Scenario: Restore one PHP Application
#    Given an accepted node
#    And a running php application
#    When I idle the php application

