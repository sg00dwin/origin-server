Feature: Setup a new application

  Scenario:
    Given an existing customer named 'mhicks'
    When I setup a new php application with name 'test_app'
    Then the application should be accessible via DNS
