@runtime_extended3
Feature: Metrics Application Sub-Cartridge
  
  Scenario: Create Delete one application with a Metrics database
    Given a v2 default node
    Given a new mock-0.1 type application
    
    When I embed a metrics-0.1 cartridge into the application
    Then a httpd process will be running
    And the metrics-0.1 cartridge instance directory will exist
    
    When I stop the metrics-0.1 cartridge
    Then a httpd process will not be running
    
    When I start the metrics-0.1 cartridge
    Then a httpd process will be running
    
    When I restart the metrics-0.1 cartridge
    Then a httpd process will be running
    
    When I destroy the application
    Then a httpd process will not be running