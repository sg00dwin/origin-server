@migration-stage
Feature: Create applications for migration testing

  Scenario Outline: Regular Application Creation
    Given the libra client tools
    And an accepted node
    When 1 <type> applications are created

  Scenarios: Regular Applications
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  diy-0.1     |
    |  mysql-5.1   |
    |  mongodb-2.0 |
    |  jenkins-1.4 |
  

  Scenario Outline: Regular Application Creation with Mongo
    Given the libra client tools
    And an accepted node
    When 1 <type> applications are created
    And the embedded mongodb-2.0 cartridge is added
    And the embedded phpmoadmin-1.0 cartridge is added
    And the embedded rockmongo-1.1 cartridge is added
    And the embedded 10gen-mms-agent-0.1 is added

  Scenarios: Regular Applications with Mongo
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  diy-0.1     |


  Scenario Outline: Regular Application Creation with MySQL
    Given the libra client tools
    And an accepted node
    When 1 <type> applications are created
    And the embedded mysql-5.1 cartridge is added
    And the embedded phpmyadmin-3.4 cartridge is added
    And the embedded cron-1.4 cartridge is added
    And the embedded metrics-0.1 cartridge is added

  Scenarios: Regular Applications with MySQL
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  diy-0.1     |

  Scenario Outline: Regular Application Creation with Postgres
    Given the libra client tools
    And an accepted node
    When 1 <type> applications are created
    And the embedded postgresql-8.4 cartridge is added

  Scenarios: Regular Applications with Postgres
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  diy-0.1     |


  Scenario Outline: Scaled Application Creation
    Given the libra client tools
    And an accepted node
    When a scaled <type> application is created

  Scenarios: Scaled Applications
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  diy-0.1     |


  Scenario Outline: Scaled Application Creation with Mongo
    Given the libra client tools
    And an accepted node
    When a scaled <type> applications are created
    And the embedded mongodb-2.0 cartridge is added
    And the embedded phpmoadmin-1.0 cartridge is added
    And the embedded rockmongo-1.1 cartridge is added
    And the embedded 10gen-mms-agent-0.1 is added

  Scenarios: Scaled Applications with Mongo
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  diy-0.1     |


  Scenario Outline: Scaled Application Creation with MySQL
    Given the libra client tools
    And an accepted node
    When a scaled <type> applications are created
    And the embedded mysql-5.1 cartridge is added
    And the embedded phpmyadmin-3.4 cartridge is added
    And the embedded cron-1.4 cartridge is added
    And the embedded metrics-0.1 cartridge is added

  Scenarios: Scaled Applications with MySQL
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  diy-0.1     |


  Scenario Outline: Scaled Application Creation with Postgres
    Given the libra client tools
    And an accepted node
    When a scaled <type> applications are created
    And the embedded postgresql-8.4 cartridge is added

  Scenarios: Scaled Applications with Postgres
    |     type     |
    |  php-5.3     |
    |  ruby-1.8    |
    |  python-2.6  |
    |  perl-5.10   |
    |  jbossas-7   |
    |  nodejs-0.6  |
    |  diy-0.1     |

