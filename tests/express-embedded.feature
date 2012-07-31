@runtime_extended
@runtime_extended3
Feature: Embedded Cartridge Verification Tests

# This feature covers the cartridges that are express specific and not available in OpenShift Origin 
# When we add any of these cartridges on the opensource side as well, we should merge this section back

  Scenario: Embedded Usage
    Given the libra client tools
    And an accepted node
    When 1 php-5.3 applications are created
    Then the applications should be accessible

    Given an existing php-5.3 application without an embedded cartridge
    When the embedded mongodb-2.0 cartridge is added
    And the embedded rockmongo-1.1 cartridge is added
    And the embedded metrics-0.1 cartridge is added
    Then the application should be accessible
    When the embedded rockmongo-1.1 cartridge is removed
    And the embedded mongodb-2.0 cartridge is removed
    And the embedded metrics-0.1 cartridge is removed

    And the embedded postgresql-8.4 cartridge is added
    And the embedded postgresql-8.4 cartridge is removed
    Then the application should be accessible

    When the application is destroyed
    Then the application should not be accessible

  #Scenario: Jenkins Client Usage
  #  Given the libra client tools
  #  And an accepted node
  #  When 1 jenkins-1.4 applications are created
  #  Then the applications should be accessible
  #  Given an existing jenkins-1.4 application without an embedded cartridge
  #  When the embedded jenkins-client-1.4 cartridge is added
  #  Then the application should be accessible
  #  When the embedded jenkins-client-1.4 cartridge is removed
  #  Then the application should be accessible
  #  When the application is destroyed
  #  Then the application should not be accessible
  
