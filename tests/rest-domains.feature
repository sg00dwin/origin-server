@api
Feature: domains
  As an API client
  In order to do things with domains
  I want to List, Create, Retrieve, Update and Delete domains
  
  Scenario: List domains
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a GET request to "/domains"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Create domain
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Retrieve domain
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a GET request to "/domains/cucumber"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
  
  Scenario: Update domain
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a PUT request to "/domains/cucumber" with the following:"namespace=cucumber1"
    Then the response should be "200"
    When I send a DELETE request to "/domains/cucumber1"
    Then the response should be "204"
    
  Scenario: Delete domain
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Create duplicate domain
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "409"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
   
  Scenario: Retrieve non-exstent domain
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a GET request to "/domains/cucumber"
    Then the response should be "404"
    
  Scenario: Delete domain with existing applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "400"
    When I send a DELETE request to "/domains/cucumber/applications/app"
    Then the response should be "204"
    When I send a DELETE request to "/domains/cucumber"
    Then the response should be "204"
    
  Scenario: Force Delete domain with existing applications
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber?force=true"
    Then the response should be "204"

    