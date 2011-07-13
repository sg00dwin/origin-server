@verify
Feature: Verification Tests
  Scenario Outline: Application Creation
    Given the libra client tools
    And an accepted node
    When <app_count> <type> applications are created
    Then the applications should be accessible

  Scenarios: Application Creation Scenarios
    | app_count |     type     |
    |     1     |  php-5.3     |
    |     1     |  wsgi-3.2    |
    |     1     |  perl-5.10   |
    |     1     |  rack-1.1    |
    |     1     |  jbossas-7.0 |

  Scenario Outline: Application Modification
    Given an existing <type> application
    When the application is changed
    Then it should be updated successfully
    And the application should be accessible

  Scenarios: Application Modification Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |

  Scenario Outline: Application Stopping
    Given an existing <type> application
    When the application is stopped
    Then the application should not be accessible

  Scenarios: Application Stopping Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |

  Scenario Outline: Application Starting
    Given an existing <type> application
    When the application is started
    Then the application should be accessible

  Scenarios: Application Starting Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |

  Scenario Outline: Application Restarting
    Given an existing <type> application
    When the application is restarted
    Then the application should be accessible

  Scenarios: Application Restart Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |

  Scenario Outline: Application Restarting From Stop
    Given an existing <type> application
    When the application is stopped
    And the application is restarted
    Then the application should be accessible

  Scenarios: Application Restarting From Stop Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |

  Scenario Outline: MySQL Embedded Creation
    Given an existing <type> application without an embedded cartridge
    When the embedded <embed> cartridge is added
    Then the application should be accessible

  Scenarios: MySQL Embedded Creation Scenarios
    |     embed     |      type     |
    |   mysql-5.1   |   php-5.3     |
    |   mysql-5.1   |   wsgi-3.2    |
    |   mysql-5.1   |   perl-5.10   |
    |   mysql-5.1   |   rack-1.1    |
    |   mysql-5.1   |   jbossas-7.0 |

  Scenario Outline: MySQL Embedded Removal
    Given an existing <type> application with an embedded <embed> cartridge
    When the embedded cartridge is removed
    Then the application should be accessible

  Scenarios: MySQL Embedded Removal Scenarios
    |     embed     |      type     |
    |   mysql-5.1   |   php-5.3     |
    |   mysql-5.1   |   wsgi-3.2    |
    |   mysql-5.1   |   perl-5.10   |
    |   mysql-5.1   |   rack-1.1    |
    |   mysql-5.1   |   jbossas-7.0 |

  Scenario Outline: Application Destroying
    Given an existing <type> application
    When the application is destroyed
    Then the application should not be accessible

  Scenarios: Application Destroying Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |
