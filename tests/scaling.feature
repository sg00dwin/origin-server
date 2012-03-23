@verify
Feature: Scaling Verification Tests
  Scenario Outline: Scaled App Creation
    Given the libra client tools
    And an accepted node
    When a scaled <type> application is created
    #Then the applications should be accessible

  Scenarios: Application Creation Scenarios
    | app_count |     type     |
    |     1     |  php-5.3     |
