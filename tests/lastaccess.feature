@runtime_extended
@runtime_extended3
Feature: Last Access Updater
  Scenario: Application Creation
    Given the libra client tools
    And an accepted node
    When 1 php-5.3 applications are created
    Then the applications should be accessible

  Scenario: Application Access
    Given an existing php-5.3 application
    Given I wait 5 seconds
    When the last access script is run
    Then the application last access file should be present

  Scenario: Application Destroying
    Given an existing php-5.3 application
    When the application is destroyed
    Then the application should not be accessible
    And the application last access file should not be present
