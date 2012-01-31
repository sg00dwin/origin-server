@verify
Feature: Cartridge Verification Tests
  Scenario Outline: Application Creation OLD
    Given the libra client tools
    And an accepted node
    When <app_count> <type> applications are created OLD
    Then the applications should be accessible

  Scenarios: Application Creation OLD Scenarios
    | app_count |     type     |
    |     1     |  php-5.3     |

  Scenario Outline: Application Stopping OLD
    Given an existing <type> application
    When the application is stopped OLD
    Then the application should not be accessible

  Scenarios: Application Stopping OLD Scenarios
    |      type     |
    |   php-5.3     |

  Scenario Outline: Application Starting OLD
    Given an existing <type> application
    When the application is started OLD
    Then the application should be accessible

  Scenarios: Application Starting OLD Scenarios
    |      type     |
    |   php-5.3     |

  Scenario Outline: Server Alias OLD
    Given an existing <type> application
    When the application is aliased OLD
    Then the application should respond to the alias

  Scenarios: Server Alias OLD Scenarios
    |      type     |
    |   php-5.3     |

  Scenario Outline: Application Restarting OLD
    Given an existing <type> application
    When the application is restarted OLD
    Then the application should be accessible

  Scenarios: Application Restarting OLD Scenarios
    |      type     |
    |   php-5.3     |

  Scenario Outline: Application Restarting From Stop OLD
    Given an existing <type> application
    When the application is stopped OLD
    And the application is restarted OLD
    Then the application should be accessible

  Scenarios: Application Restarting From Stop OLD Scenarios
    |      type     |
    |   php-5.3     |
    
  Scenario Outline: Application Change Namespace OLD
    Given an existing <type> application
    When the application namespace is updated OLD
    Then the application should be accessible

  Scenarios: Application Change Namespace OLD Scenarios
    |      type     |
    |   php-5.3     |
    
  Scenario Outline: Application Snapshot OLD
    Given an existing <type> application
    When I snapshot the application OLD
    Then the application should be accessible
    When I restore the application OLD
    Then the application should be accessible

  Scenarios: Application Snapshot OLD Scenarios
    |      type     |
    |   php-5.3     |

  Scenario Outline: Application Tidy OLD
    Given an existing <type> application
    When I tidy the application OLD
    Then the application should be accessible

  Scenarios: Application Tidy OLD Scenarios
    |      type     |
    |   php-5.3     |

  Scenario Outline: Application Destroying OLD
    Given an existing <type> application
    When the application is destroyed OLD
    Then the application should not be accessible

  Scenarios: Application Destroying OLD Scenarios
    |      type     |
    |   php-5.3     |