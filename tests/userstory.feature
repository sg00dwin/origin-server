@verify
Feature: Rally User Stories

#US37 - TC21, TC29, TC3
  Scenario: Destroy PHP Application through rhc-ctl-app by user(TC21)
    Given the libra client tools
    When create a new php-5.3.2 app 'appphp0'
    Then the PHP app can be accessible
    When destroy this PHP app using rhc-ctl-app
    Then the PHP app should not be accessible

  Scenario: libra app environment can be customized(TC29)
    Given the libra client tools
    When create a new php-5.3.2 app 'appphp1'
    Then new app created under the generated git repo path
    When create app with -n option
    Then only create remote space and do not pull it locally

  Scenario: Destroy PHP Application through rhc-ctl-app by user(TC3)
    Given the libra client tools
    When create a new php-5.3.2 app 'appphp2'
    Then the PHP app can be accessible
    When check the status of this app using rhc-ctl-app
    Then this PHP app is running
    When stop this PHP app
    And check the status of this app using rhc-ctl-app
    Then this PHP app is stopped
    When start this PHP app
    And check the status of this app using rhc-ctl-app
    Then this PHP app is running
    When restart this PHP app
    Then this PHP app is restarted
    When reload this PHP app
    Then this PHP app is reloaded
    
    
#US362 - TC115
  Scenario: negative testing of client command(TC115)
    Given the libra client tools
    And create a domain
    When create an app without -a
    Then throw out an error application is required
    When create an app without -t
    Then throw out an error Type is required
    When create a new rack-1.1.0 app 'apprails0'
    And using rhc-ctl-app without -c
    Then throw out an error Command is required
    When using rhc-ctl-app without -a
    Then throw out an error application is required

#US59 - TC18, TC52, TC54, TC55, TC56
  Scenario: SELinux separation - Create app(TC18)
    Given the libra client tools
    When check SELinux status
    Then SELinux is running in enforcing mode
    When check whether SELinux module for Libra is installed
    Then Selinux for Libra is installed
    When check whether SELinux audit service is running on the node
    And start SELinux audit service if it is stopped
    Then SELinux audit service is running
    When clean old audit.log
    And create an rack-1.1.0 app
    And check audit.log for AVC denials
    Then no AVC denials
    When stop the rack-1.1.0 app
    And check audit.log for AVC denials
    Then no AVC denials
    When start the rack-1.1.0 app
    And check audit.log for AVC denials
    Then no AVC denials
    When restart the rack-1.1.0 app
    And check audit.log for AVC denials
    Then no AVC denials
    When reload the rack-1.1.0 app
    And check audit.log for AVC denials
    Then no AVC denials
    When destroy the rack-1.1.0 app
    And check audit.log for AVC denials
    Then no AVC denials


    
#US280 - TC19
  Scenario: Log in cloud website
    Given a Mechanize agent and a registered user
    Then can access our cloud website
    Then can login our cloud website

#US414 - Reduce number of apps per user to be 1
  Scenario: the number of apps per user is 1
    Given the libra controller configuration
    Then the number of apps per user is 1

#US27
  Scenario: per user app limit
    When create a new php-5.3.2 app 'appphp3'
    Then the PHP app can be accessible
    Then would fail to create the second 'appphp4' application for 'php-5.3.2'




    
    