@performance
Feature: Application Performance Tests
  Scenario Outline: Application Creation
    Given the libra client tools
    And an accepted node
    When 1 <type> applications are created

  Scenarios: Application Scenarios
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  ruby-1.9    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  jenkins-1.4 |
    |  diy-0.1     |

  Scenario Outline: Add and Remove Embedded Cartridegs
    Given an existing <type> application without an embedded cartridge
    When the embedded mysql-5.1 cartridge is added
    And the embedded phpmyadmin-3.4 cartridge is added
    When the embedded phpmyadmin-3.4 cartridge is removed
    And the embedded mysql-5.1 cartridge is removed
    When the embedded mongodb-2.2 cartridge is added
    And the embedded rockmongo-1.1 cartridge is added
    When the embedded rockmongo-1.1 cartridge is removed
    And the embedded mongodb-2.2 cartridge is removed
    And the embedded postgresql-8.4 cartridge is added
    And the embedded postgresql-8.4 cartridge is removed
    And the embedded cron-1.4 cartridge is added
    And the embedded cron-1.4 cartridge is removed
    And the embedded metrics-0.1 cartridge is added
    And the embedded metrics-0.1 cartridge is removed
    And the embedded haproxy-1.4 cartridge is added
    And the embedded haproxy-1.4 cartridge is removed

  Scenarios: Embedded Cartridge Scenarios
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  ruby-1.9    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  jenkins-1.4 |
    |  diy-0.1     |

  Scenario Outline: Namespace Change, Application Alias, Sanpshot, Start, Stop, Restart and Destroy
    Given an existing <type> application
    When I snapshot the application
    When I restore the application
    When the application is aliased
    When the application is unaliased
    When the application namespace is updated
    When the application is started
    When the application is stopped
    When the application is restarted
    When the application is destroyed

  Scenarios: Application Scenarios
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  ruby-1.9    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  jenkins-1.4 |
    |  diy-0.1     |
