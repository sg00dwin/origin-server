@node
@broker
Feature: Mongo standalone verification
  Scenario Outline: Mongo Scale App
    Given the libra client tools
    And an accepted node
    When a scaled <type> application is created
    Then the haproxy-status page will be responding
    And the gear members will be UP
    And the <type> health-check will be successful
    And 1 gears will be in the cluster
    When mongo is added to the scaled app
    Then app should be able to connect to mongo
    When haproxy_ctld_daemon is stopped
    And a gear is added
    Then 2 gears will be in the cluster
    And the <type> health-check will be successful
    And the <type> health-check will be successful
    Then app should be able to connect to mongo
    When a gear is removed
    Then 1 gears will be in the cluster
    Then app should be able to connect to mongo
    And the <type> health-check will be successful
    When the application is destroyed
    Then the application should not be accessible
    And the <type> health-check will not be successful

  Scenarios: Mongo Scaled App Scenarios
    | app_count |     type     |
    |     1     |  php-5.3     |
