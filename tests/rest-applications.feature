@api
Feature: applications
  As an API client
  In order to do things with domains
  I want to List, Create, Retrieve, Start, Stop, Restart, Force-stop and Delete applications
  
  Scenario: List applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a GET request for "/domains/cucumber/applications"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Create applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a GET request for "/domains/cucumber/applications"
    Then the response should be "200"
    When I send a GET request for "/domains/cucumber/applications/app"
    Then the response should be "200"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "409"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app1&cartridge=bogus"
    Then the response should be "400"
    When I send a POST request to "/domains/cucumber/applications/app1/events" with the following:"event=start"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app1/events" with the following:"event=stop"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app1/events" with the following:"event=restart"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app1/events" with the following:"event=force-stop"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Retrieve applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a GET request for "/domains/cucumber/applications/app"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Start applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app1/events" with the following:"event=start"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Stop applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app1/events" with the following:"event=stop"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Restart applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app1/events" with the following:"event=restart"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Force-stop applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications/app1/events" with the following:"event=force-stop"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
  
  Scenario: Delete applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
  
  Scenario: Create duplicate application
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "409"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Create application with invalid cartridge
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber&ssh=XYZ123ABC456"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app1&cartridge=bogus"
    Then the response should be "400"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "404"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    

    
    
    
  
  
  