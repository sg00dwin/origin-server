@internals
Feature: phpMyAdmin Embedded Cartridge

  Scenario Outline: Add phpMyAdmin to one application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mysql database
    When I configure phpmyadmin
    Then a phpmyadmin http proxy file will exist
    And a phpmyadmin httpd will be running
    And the phpmyadmin directory will exist
    And phpmyadmin log files will exist
    And the phpmyadmin control script will exist

  Scenarios: Add phpMyAdmin to one Application Scenarios
    |type|
    |php|
    |wsgi|
    |jbossas|
    |perl|
    |rack|


  Scenario Outline: Remove phpMyAdmin from one Application
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mysql database
    And a new phpmyadmin
    When I deconfigure phpmyadmin
    Then a phpmyadmin http proxy file will not exist
    And a phpmyadmin httpd will not be running
    And the phpmyadmin directory will not exist
    And phpmyadmin log files will not exist
    And the phpmyadmin control script will not exist

  Scenarios: Remove phpMyAdmin from one Application Scenarios
    |type|
    |php|
    |wsgi|
    |jbossas|
    |perl|
    |rack|


  Scenario Outline: Start phpMyAdmin
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mysql database
    And a new phpmyadmin
    And phpmyadmin is stopped
    When I start phpmyadmin
    Then a phpmyadmin httpd will be running

  Scenarios: Start phpMyAdmin scenarios
    |type|
    |php|
    |wsgi|
    |jbossas|
    |perl|
    |rack|


  Scenario Outline: Stop phpMyAdmin
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mysql database
    And a new phpmyadmin
    And phpmyadmin is running
    When I stop phpmyadmin
    Then a phpmyadmin httpd will not be running

  Scenarios: Stop phpMyAdmin scenarios
    |type|
    |php|
    |wsgi|
    |jbossas|
    |perl|
    |rack|


  Scenario Outline: Restart phpMyAdmin
    Given an accepted node
    And a new guest account
    And a new <type> application
    And a new mysql database
    And a new phpmyadmin
    And phpmyadmin is running
    When I restart phpmyadmin
    Then a phpmyadmin httpd will be running

  Scenarios: Restart phpMyAdmin scenarios
    |type|
    |php|
    |wsgi|
    |jbossas|
    |perl|
    |rack|
