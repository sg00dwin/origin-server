@api
Feature: applications
  As an API client
  In order to do things with domains
  I want to List, Create, Retrieve, Start, Stop, Restart, Force-stop and Delete applications
  
  Scenario: List applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a GET request to "/domains/cucumber/applications"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    
  Scenario: Create application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    
  Scenario: Create application with blank, missing, invalid name
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=&cartridge=php-5.3"
    Then the response should be "422"
    When I send a POST request to "/domains/cucumber/applications" with the following:"cartridge=php-5.3"
    Then the response should be "422"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app?one&cartridge=php-5.3"
    Then the response should be "422"
    
  Scenario: Retrieve application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a GET request to "/domains/cucumber/applications/app"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    
  Scenario: Start application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app/events" with the following:"event=start"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    
  Scenario: Stop application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app/events" with the following:"event=stop"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    
  Scenario: Restart application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app/events" with the following:"event=restart"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    
  Scenario: Force-stop application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app/events" with the following:"event=force-stop"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
  
  Scenario: Delete application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
  
  Scenario: Create duplicate application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "409"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    
  Scenario: Create application with invalid or missing cartridge
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=bogus"
    Then the response should be "422"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app"
    Then the response should be "422"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "404"
  
  Scenario: Retrieve or delete a non-existent application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a GET request to "/domains/cucumber/applications/app"
    Then the response should be "404"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "404"

  Scenario: Retrieve application descriptor
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app/cartridges" with the following:"cartridge=postgresql-8.4"
    Then the response should be "201"
	When I send a GET request to "/domains/cucumber/applications/app/descriptor"
    Then the response descriptor should have "php-5.3,postgresql-8.4" as dependencies
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
  
    
    
  
  
  