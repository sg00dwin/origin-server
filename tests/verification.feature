@verify
Feature: Verification Tests
  Scenario Outline: Application Creation
    Given the libra client tools
    And an accepted node
    When <app_count> <type> applications are created
    Then they should be accessible

  Scenarios: Application Creation Scenarios
    | app_count |     type     |
    |     1     |  php-5.3     |
    |     1     |  wsgi-3.2    |
    |     1     |  perl-5.10   |
    |     1     |  rack-1.1    |
    |     1     |  jbossas-7.0 |

  Scenario Outline: Application Modification
    Given an existing <type> application
    When that application is changed
    Then it should be updated successfully
    And it should be accessible

  Scenarios: Application Modification Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |

  Scenario Outline: Application Stopping
    Given an existing <type> application
    When that application is stopped
    Then it should not be accessible

  Scenarios: Application Stopping Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |

  Scenario Outline: Application Starting
    Given an existing <type> application
    When that application is started
    Then it should be accessible

  Scenarios: Application Starting Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |

  Scenario Outline: Application Restarting
    Given an existing <type> application
    When that application is restarted
    Then it should be accessible

  Scenarios: Application Restart Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |

  Scenario Outline: Application Restarting From Stop
    Given an existing <type> application
    When that application is stopped
    And that application is restarted
    Then it should be accessible

  Scenarios: Application Restarting From Stop Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |

  Scenario Outline: Application Destroying
    Given an existing <type> application
    When that application is destroyed
    Then it should not be accessible

  Scenarios: Application Restarting From Stop Scenarios
    |      type     |
    |   php-5.3     |
    |   wsgi-3.2    |
    |   perl-5.10   |
    |   rack-1.1    |
    |   jbossas-7.0 |
