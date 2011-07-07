@internals
Feature: PHP Application

  # runcon -u ?? -r system_r -t libra_initrc_t

  Scenario: Create one PHP Application
    Given an accepted node
    And a new guest account
    And the guest account has no application installed
    When I configure a PHP application
    Then a php application http proxy file will exist
    And a php application git repo will exist
    And a php application source tree will exist
    And a php application httpd will be running 
    And php application log files will exist

#  Scenario: Delete one PHP Application
#    Given an accepted node
#    And a new guest account
#    And a new PHP application
#    When I deconfigure the PHP application
#    Then a php application http proxy file will not exist
#    And a php application git repo will not exist
#    And a php application source tree will not exist
#    And a php application httpd will not be running


#  Scenario: Start a PHP Application
#    Given an accepted node
#    And a new guest account
#    And a new PHP application
#    And the php application is stopped
#    When I start the PHP application
#    Then a php application httpd will be running


#  Scenario: Start a PHP Application
#    Given an accepted node
#    And a new guest account
#    And a new PHP application
#    And the php application is running
#    When I stop the PHP application
#    Then a php application httpd will not be running
