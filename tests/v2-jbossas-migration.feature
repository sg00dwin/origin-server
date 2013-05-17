@runtime_migration
Feature: V2 Migrations for V1 apps
 Scenario: jbossas-7 app migration
    Given a new client created jbossas-7 application
    Given the application has a USER_VARS env file
    Then the application should be accessible

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the application will be marked as a v2 app
    And the application should be accessible
    And the USER_VARS file will not exist
    And the migration metadata will be cleaned up

    When the application is changed
    Then it should be updated successfully
    And the application should be accessible

  Scenario: Stopped jbossas-7 app migration
    Given a new client created jbossas-7 application
    And the application is stopped

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the application will be marked as a v2 app
    And the application should not be accessible
    And the migration metadata will be cleaned up

  Scenario: jbossas-7 + mysql-5.1 migration
    Given a new client created jbossas-7 application
    Given the embedded mysql-5.1 cartridge is added
    Then I can select from mysql

    When I insert test data into mysql
    Then the test data will be present in mysql

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the application will be marked as a v2 app
    And the application should be accessible
    And I can select from mysql
    And the test data will be present in mysql
    And the migration metadata will be cleaned up

  Scenario: Scaled jbossas-7 app migration
    Given a new client created scalable jbossas-7 application
    And the minimum scaling parameter is set to 2
    And the application has a USER_VARS env file
    Then the application should be accessible

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the application will be marked as a v2 app
    And the application should be accessible
    And the USER_VARS file will not exist
    And the migration metadata will be cleaned up

    When the application is changed
    Then it should be updated successfully
    And the application should be accessible

  Scenario: Scaled jbossas-7 + mysql-5.1 migration
    Given a new client created scalable jbossas-7 application
    Given the embedded mysql-5.1 cartridge is added
    Then I can select from mysql

    When I insert test data into mysql
    Then the test data will be present in mysql

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the application will be marked as a v2 app
    And the application should be accessible
    And I can select from mysql
    And the test data will be present in mysql
    And the migration metadata will be cleaned up
