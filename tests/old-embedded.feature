@verify
Feature: Embedded Cartridge Verification Tests OLD
  Scenario: Application Creation OLD
    Given the libra client tools
    And an accepted node
    When 1 php-5.3 applications are created OLD
    Then the applications should be accessible

  Scenario: MySQL Embedded Creation
    Given an existing php-5.3 application without an embedded cartridge
    When the embedded mysql-5.1 cartridge is added OLD
    Then the application should be accessible

  Scenario: MySQL Embedded Usage OLD
    Given an existing php-5.3 application with an embedded mysql-5.1 cartridge
    When the application uses mysql 
    Then the application should be accessible
    And the mysql response is successful

  Scenario: MySQL Embedded Removal OLD
    Given an existing php-5.3 application with an embedded mysql-5.1 cartridge
    When the embedded cartridge is removed OLD
    Then the application should be accessible

  Scenario: Application Destroying OLD
    Given an existing php-5.3 application
    When the application is destroyed OLD
    Then the application should not be accessible
    
  Scenario: Jenkins Creation OLD
    Given the libra client tools
    And an accepted node
    When 1 jenkins-1.4 applications are created OLD
    Then the applications should be accessible

  Scenario: Jenkins Client Embedded Creation OLD
    Given an existing jenkins-1.4 application without an embedded cartridge
    When the embedded jenkins-client-1.4 cartridge is added OLD
    Then the application should be accessible

  Scenario: Jenkins Client Embedded Removal OLD
    Given an existing jenkins-1.4 application with an embedded jenkins-client-1.4 cartridge
    When the embedded cartridge is removed OLD
    Then the application should be accessible

  Scenario: Jenkins Destroying OLD
    Given an existing jenkins-1.4 application
    When the application is destroyed OLD
    Then the application should not be accessible