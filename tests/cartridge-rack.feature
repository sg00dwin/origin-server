@internals
Feature: RACK Application

  # runcon -u ?? -r system_r -t libra_initrc_t

  Scenario: Create one RACK Application
    Given an accepted node
    And a new guest account
    And the guest account has no application installed
    When I configure a rack application
    Then a rack application http proxy file will exist
    And a rack application git repo will exist
    And a rack application source tree will exist
    And a rack application httpd will be running 
    And rack application log files will exist

  Scenario: Delete one RACK Application
    Given an accepted node
    And a new guest account
    And a new rack application
    When I deconfigure the rack application
    Then a rack application http proxy file will not exist
    And a rack application git repo will not exist
    And a rack application source tree will not exist
    And a rack application httpd will not be running


  Scenario: Start a RACK Application
    Given an accepted node
    And a new guest account
    And a new rack application
    And the rack application is stopped
    When I start the rack application
    Then the rack application will be running
    And a rack application httpd will be running


  Scenario: Stop a RACK Application
    Given an accepted node
    And a new guest account
    And a new rack application
    And the rack application is running
    When I stop the rack application
    Then the rack application will not be running
    And a rack application httpd will not be running
