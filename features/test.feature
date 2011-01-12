Feature: Setup a new application

  Scenario:
    Given a customer existing with name 'test_cust'
    When I setup a new php application with name 'test_app'
    Then the application should be accessible via DNS

  Scenario:
    Given existing servers with git repositories
    When I request a new machine to put an application on
    Then I should get the server with the least amount of repositories
