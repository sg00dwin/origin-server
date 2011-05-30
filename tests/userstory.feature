@verify
Feature: Rally User Stories

#US37 - TC21, TC29, TC3
  Scenario: (libra-qe) Destroy a PHP Application by user with rhc-ctl-app (TC21)
    Given the libra client tools
    When a new php-5.3 app 'appphp0' is created
    Then the PHP app is accessible
    When the PHP app is destroyed using rhc-ctl-app
    Then the PHP app is not accessible

  Scenario: (libra-qe) Customize libra app environment (TC29)
    Given the libra client tools
    When a new php-5.3 app 'appphp1' is created
    Then the new app is created under the generated git repo path
    When an app is created with -n option
    Then only the remote space is created and it is not pulled in locally

  Scenario: (libra-qe) Destroy a PHP Application by user with rhc-ctl-app (TC3)
    Given the libra client tools
    When a new php-5.3 app 'appphp2' is created
    Then the PHP app is accessible
    When the status of this app is checked using rhc-ctl-app
    Then this PHP app is running
    When I stop this PHP app
    And the status of this app is checked using rhc-ctl-app
    Then this PHP app is stopped
    When I start this PHP app
    And the status of this app is checked using rhc-ctl-app
    Then this PHP app is running
    When I restart this PHP app
    Then this PHP app is restarted
    When I reload this PHP app
    Then this PHP app is reloaded

#US362 - TC115
  Scenario: (libra-qe) Negative testing of client command (TC115)
    Given the libra client tools
    And a created domain 
    When an app is created without -a
    Then display an error that the application is required
    When an app is created without -t
    Then display an error that the type is required
    When a new rack-1.1 app 'apprails0' is created
    And rhc-ctl-app is run without -c
    Then display an error that the command is required
    When rhc-ctl-app is run without -a
    Then display an error that the application is required

#US59 - TC18, TC52, TC54, TC55, TC56
  Scenario: (libra-qe) SELinux separation - Create app (TC18)
    Given the libra client tools
    When SELinux status is checked
    Then SELinux is running in enforcing mode
    When SELinux module for Libra is checked to see if it is installed
    Then Selinux for Libra is installed
    When SELinux audit service is checked to see if it is running on the node
    And SELinux audit service is started if it is stopped
    Then SELinux audit service is running
    When old audit.log is cleaned
    And a rack-1.1 app is created
    And audit.log is checked for AVC denials
    Then there are no AVC denials
    When the rack-1.1 app is stopped
    And audit.log is checked for AVC denials
    Then there are no AVC denials
    When the rack-1.1 app is started
    And audit.log is checked for AVC denials
    Then there are no AVC denials
    When the rack-1.1 app is restarted
    And audit.log is checked for AVC denials
    Then there are no AVC denials
    When the rack-1.1 app is reloaded
    And audit.log is checked for AVC denials
    Then there are no AVC denials
    When the rack-1.1 app is destroyed
    And audit.log is checked for AVC denials
    Then there are no AVC denials


#US280 - TC19
  Scenario: (libra-qe) Log in to the cloud website
    Given a Mechanize agent and a registered user
    Then the user can access our cloud website
    Then the user can log in to our cloud website

#US414 - Reduce the number of apps per user to 1
  Scenario: (libra-qe) The number of apps per user is 1
    Given the libra controller configuration
    Then the number of apps per user is 1

#US27
  Scenario: (libra-qe) Per user app limit
    Given the libra client tools
    When a new php-5.3 app 'appphp1' is created
    Then the PHP app is accessible
    Then a second 'appphp2' application for 'php-5.3' fails to be created

#US346
  Scenario: (libra-qe) Rack/Rails Framework Support
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   1   |  1   | rack-1.1   |
    When the applications are created
    Then they are accessible within 30 seconds
    Then users can create a new rails app using rails new
