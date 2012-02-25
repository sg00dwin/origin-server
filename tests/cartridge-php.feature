@internals
Feature: PHP Application

  # runcon -u ?? -r system_r -t libra_initrc_t

  Scenario: Create Delete one PHP Application
    Given an accepted node
    And a new guest account
    And the guest account has no application installed
    When I configure a php application
    Then a php application http proxy file will exist
    And a php application git repo will exist
    And a php application source tree will exist
    And a php application httpd will be running 
    And php application log files will exist
    When I deconfigure the php application
    Then a php application http proxy file will not exist
    And a php application git repo will not exist
    And a php application source tree will not exist
    And a php application httpd will not be running

  Scenario: Stop Start a PHP Application
    Given an accepted node
    And a new guest account
    And a new php application
    And the php application is running
    When I stop the php application
    Then the php application will not be running
    And a php application httpd will not be running
    And the php application is stopped
    When I start the php application
    Then the php application will be running
    And a php application httpd will be running

  Scenario: Add Remove Alias a PHP Application
    Given an accepted node
    And a new guest account
    And a new php application
    And the php application is running
    When I add-alias the php application
    Then the php application will be aliased
    When I remove-alias the php application
    Then the php application will not be aliased 
    

  Scenario: Enable Disable Proxy a PHP Application
    Given an accepted node
    And a new guest account
    And a new php application
    And the php application is running
    When I expose-port the php application
    Then the php application will be exposed
    When I conceal-port the php application
    Then the php application will not be exposed
