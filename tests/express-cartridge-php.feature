@runtime
@runtime2
Feature: PHP Application

# This feature has the expose/conceal/show port carved out of the cartridge-php.feature 
# since these are express-ONLY features as of now
# When we support these features on the opensource side as well, we should merge this section back

  # runcon -u ?? -r system_r -t libra_initrc_t

  Scenario: Create Delete one PHP Application
    Given a new php-5.3 type application
    Then the application http proxy file will exist
    And the application git repo will exist
    And the application source tree will exist
    And a httpd process will be running

    #Given a new guest account
    #And the guest account has no application installed
    #When I configure a php application
    #And the php file permissions are correct
 
    When I expose-port the php application
    Then the php application will be exposed
    When I conceal-port the php application
    Then the php application will not be exposed

    When I destroy the application
    Then the application http proxy file will not exist
    And a httpd process will not be running
    And the application git repo will not exist
    And the application source tree will not exist

#
#?  Scenario: Create Delete one PHP Application
#?    Given a new guest account
#?    And the guest account has no application installed
#?    When I configure a php application
#?    Then a php application http proxy file will exist
#?    And a php application git repo will exist
#?    And a php application source tree will exist
#?    And a php application httpd will be running 
#?    And the php file permissions are correct
#? 
#?    When I expose-port the php application
#?    Then the php application will be exposed
#?    When I conceal-port the php application
#?    Then the php application will not be exposed
#?
#?    When I deconfigure the php application
#?    Then a php application http proxy file will not exist
#?    And a php application git repo will not exist
#?    And a php application source tree will not exist
#?    And a php application httpd will not be running
