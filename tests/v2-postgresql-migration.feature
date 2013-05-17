@runtime_migration
Feature: V2 Migrations for V1 apps
  Scenario: PHP + Postgres migration
    Given a new client created php-5.3 application
    Given the embedded postgresql-8.4 cartridge is added

    When I create a test table in postgres
    Then I insert test data into postgres
    And the test data will be present in postgres

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the application will be marked as a v2 app
    And the application should be accessible
    And the test data will be present in postgres
    And the migration metadata will be cleaned up

  Scenario: Scalable PHP + Postgres app migration
    Given a new client created scalable php-5.3 application
    Given the embedded postgresql-8.4 cartridge is added
    Then the application has a USER_VARS env file
    And the application has a TYPELESS_TRANSLATED_VARS env file
    And the application has a TRANSLATE_GEAR_VARS env file
    And the application should be accessible

    When I create a test table in postgres
    Then I insert test data into postgres
    And the test data will be present in postgres

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the postgresql uservars entries will be migrated to a namespaced env directory
    And the application will be marked as a v2 app

    And the application should be accessible
    And the test data will be present in postgres

    And the USER_VARS file will not exist
    And the TRANSLATE_GEAR_VARS file will not exist
    And the TYPELESS_TRANSLATED_VARS variables will be discrete variables
    And the migration metadata will be cleaned up
