@runtime_migration
@v2_ruby_migration
@v2_ruby_18_migration
Feature: V2 Migrations for V1 apps
  Scenario: Ruby app migration
    Given a new client created ruby-1.8 application
    Given the application has a USER_VARS env file
    Given the application has a TYPELESS_TRANSLATED_VARS env file
    Given the application has a TRANSLATE_GEAR_VARS env file
    Then the application should be accessible

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the application will be marked as a v2 app
    And the application should be accessible
    And the USER_VARS file will not exist
    And the TRANSLATE_GEAR_VARS file will not exist
    And the TYPELESS_TRANSLATED_VARS variables will be discrete variables
    And the migration metadata will be cleaned up

  Scenario: Stopped Ruby app migration
    Given a new client created ruby-1.8 application
    And the application is stopped

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the application will be marked as a v2 app
    And the application should not be accessible
    And the migration metadata will be cleaned up

  Scenario: Ruby + Mysql migration
    Given a new client created ruby-1.8 application
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
