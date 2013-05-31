@runtime_migration
Feature: V2 Migrations for V1 apps with switchyard
 Scenario: jbossas-7 + switchyard app migration
    Given a new client created jbossas-7 application
    And the embedded switchyard-0.6 cartridge is added
    Then the application should be accessible

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the switchyard env variables will be cleaned up
    And the switchyard cartridge directory will exist
    And the application will be marked as a v2 app
    And the application should be accessible
    And the migration metadata will be cleaned up

    When the application is changed
    Then it should be updated successfully
    And the application should be accessible

Scenario: jbosseap-6.0 + switchyard app migration
    Given a new client created jbosseap-6.0 application
    And the embedded switchyard-0.6 cartridge is added
    Then the application should be accessible

    When the application is migrated to the v2 cartridge system
    Then the environment variables will be migrated to raw values
    And the switchyard env variables will be cleaned up
    And the switchyard cartridge directory will exist
    And the application will be marked as a v2 app
    And the application should be accessible
    And the migration metadata will be cleaned up

    When the application is changed
    Then it should be updated successfully
    And the application should be accessible
