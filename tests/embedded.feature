@verify
Feature: Embedded Cartridge Verification Tests
  Scenario: Application Creation
    Given the libra client tools
    And an accepted node
    When 1 php-5.3 applications are created
    Then the applications should be accessible

  Scenario: MySQL Embedded Creation
    Given an existing php-5.3 application without an embedded cartridge
    When the embedded mysql-5.1 cartridge is added
    Then the application should be accessible

  Scenario: MySQL Embedded Usage
    Given an existing php-5.3 application with an embedded mysql-5.1 cartridge
    When the application uses mysql
    Then the application should be accessible
    And the mysql response is successful

  Scenario: MySQL Embedded Removal
    Given an existing php-5.3 application with an embedded mysql-5.1 cartridge
    When the embedded cartridge is removed
    Then the application should be accessible

  Scenario: Application Destroying
    Given an existing php-5.3 application
    When the application is destroyed
    Then the application should not be accessible
    
  Scenario: Jenkins Creation
    Given the libra client tools
    And an accepted node
    When 1 jenkins-1.4 applications are created
    Then the applications should be accessible

  Scenario: Jenkins Client Embedded Creation
    Given an existing jenkins-1.4 application without an embedded cartridge
    When the embedded jenkins-client-1.4 cartridge is added
    Then the application should be accessible

  Scenario: Jenkins Client Embedded Removal
    Given an existing jenkins-1.4 application with an embedded jenkins-client-1.4 cartridge
    When the embedded cartridge is removed
    Then the application should be accessible

  Scenario: Jenkins Destroying
    Given an existing jenkins-1.4 application
    When the application is destroyed
    Then the application should not be accessible
