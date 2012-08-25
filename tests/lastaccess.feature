@runtime
Feature: Last Access Updater

  #Disabled as last access script now filters local machine
  #@runtime_extended
  #@runtime_extended3
  Scenario: Application Creation
    Given the libra client tools
    And an accepted node
    And 1 php-5.3 applications are created
    Then the applications should be accessible

    Given an existing php-5.3 application
    Then I wait 5 seconds
    And the last access script is run
    Then the application last access file should be present

    When the application is destroyed
    Then the application should not be accessible
    And the application last access file should not be present
