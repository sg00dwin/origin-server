@verify
Feature: Scaling Verification Tests
  Scenario Outline: Scaled App Creation
    Given the libra client tools
    And an accepted node
    When a scaled <type> application is created
    Then the haproxy-status page will be responding
    And the gear member will be UP
    And the <type> health-check will be successful
    And 1 gears will be in the cluster
    #When a gear is added
    #Then 2 gears will be in the cluster
    #Then the applications should be accessible

  Scenarios: Application Creation Scenarios
    | app_count |     type     |
    |     1     |  php-5.3     |
