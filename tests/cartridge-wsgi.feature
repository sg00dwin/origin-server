@internals
Feature: WSGI Application

  # runcon -u ?? -r system_r -t libra_initrc_t

  Scenario: Create one WSGI Application
    Given an accepted node
    And a new guest account
    And the guest account has no application installed
    When I configure a wsgi application
    Then a wsgi application http proxy file will exist
    And a wsgi application git repo will exist
    And a wsgi application source tree will exist
    And a wsgi application httpd will be running 
    And wsgi application log files will exist

  Scenario: Delete one WSGI Application
    Given an accepted node
    And a new guest account
    And a new wsgi application
    When I deconfigure the wsgi application
    Then a wsgi application http proxy file will not exist
    And a wsgi application git repo will not exist
    And a wsgi application source tree will not exist
    And a wsgi application httpd will not be running


  Scenario: Start a WSGI Application
    Given an accepted node
    And a new guest account
    And a new wsgi application
    And the wsgi application is stopped
    When I start the wsgi application
    Then the wsgi application will be running
    And a wsgi application httpd will be running


  Scenario: Stop a WSGI Application
    Given an accepted node
    And a new guest account
    And a new wsgi application
    And the wsgi application is running
    When I stop the wsgi application
    Then the wsgi application will not be running
    And a wsgi application httpd will not be running
