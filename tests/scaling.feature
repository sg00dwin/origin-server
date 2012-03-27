@verify
Feature: Scaling Verification Tests
  Scenario Outline: Scale App
    Given the libra client tools
    And an accepted node
    When a scaled <type> application is created
    Then the haproxy-status page will be responding
    And the gear member will be UP
    And the <type> health-check will be successful
    And 1 gears will be in the cluster
    When a gear is added
    Then 2 gears will be in the cluster
    # This is doubled up to hit both gears
    And the <type> health-check will be successful
    And the <type> health-check will be successful
    When a gear is removed
    Then 1 gears will be in the cluster
    And the <type> health-check will be successful
    When the application is destroyed
    Then the application should not be accessible
    And the <type> health-check will not be successful

  Scenarios: Scaled App Scenarios
    | app_count |     type     |
    |     1     |  php-5.3     |

  Scenario Outline: AutoScale App
    Given the libra client tools
    And an accepted node
    When a scaled <type> application is created
    Then the haproxy-status page will be responding
    And the gear member will be UP
   And the <type> health-check will be successful
    When haproxy_ctld_daemon is restarted
    Then haproxy_ctld is running
    And 1 gears will be in the cluster
    When 15 concurrent http connections are generated for 90 seconds
    Then 2 gears will be in the cluster
    When the application is destroyed
    Then the application should not be accessible
    And the <type> health-check will not be successful

  Scenarios: AutoScale App Scenarios
   | app_count |     type     |
   |     1     |  php-5.3     |
