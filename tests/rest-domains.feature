@api
Feature: domains
  As an API client
  In order to do things with domains
  I want to List, Create, Retrieve, Update and Delete domains
  
  Scenario Outline: List domains
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a GET request to "/domains"
    Then the response should be "200"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Create domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    And the response should be a "domain" with attributes "namespace=cucumber<random>"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Create domain with blank, missing, too long and invalid namespace
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace="
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=106"
    When I send a POST request to "/domains" with the following:""
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=106"
    When I send a POST request to "/domains" with the following:"namespace=cucum?ber"
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=106"
    When I send a POST request to "/domains" with the following:"namespace=cucumbercucumbercucumbercucumbercucumbercucumbercucumbercucumber"
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=106"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Retrieve domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a GET request to "/domains/cucumber<random>"
    Then the response should be "200"
    And the response should be a "domain" with attributes "namespace=cucumber<random>"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Retrieve non-existent domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a GET request to "/domains/cucumber<random>"
    Then the response should be "404"
    And the error message should have "severity=error&exit_code=127"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Update domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a PUT request to "/domains/cucumber<random>" with the following:"namespace=cucumberX<random>"
    Then the response should be "200"
    And the response should be a "domain" with attributes "namespace=cucumberX<random>"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Update domain with blank, missing, too long and invalid namespace
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a PUT request to "/domains/cucumber<random>" with the following:"namespace="
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=106"
    When I send a PUT request to "/domains/cucumber<random>" with the following:""
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=106"
    When I send a PUT request to "/domains/cucumber<random>" with the following:"namespace=cucumber?"
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=106"
    When I send a PUT request to "/domains/cucumber<random>" with the following:"namespace=cucumbercucumbercucumbercucumbercucumbercucumbercucumbercucumber"
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=106"
    When I send a GET request to "/domains/cucumber<random>"
    Then the response should be "200"
    And the response should be a "domain" with attributes "namespace=cucumber<random>"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Update non-existent domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a PUT request to "/domains/cucumberX<random>" with the following:"namespace=cucumberY<random>"
    Then the response should be "404"
    And the error message should have "severity=error&exit_code=127"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Update domain with applications
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber<random>/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a PUT request to "/domains/cucumber<random>" with the following:"namespace=cucumberX<random>"
    Then the response should be "200"
    And the response should be a "domain" with attributes "namespace=cucumberX<random>"
    
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
     
  Scenario Outline: Update the domain of another user
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    Given a new guest account
    And I am a valid user
    When I send a PUT request to "/domains/cucumber<random>" with the following:"namespace=cucumberX<random>"
    Then the response should be "404"
    And the error message should have "severity=error&exit_code=127"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
     
  Scenario Outline: Delete domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber<random>"
    Then the response should be "204"
    When I send a GET request to "/domains/cucumber<random>"
    Then the response should be "404"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML |
      
  Scenario Outline: Delete non-existent domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumberX<random>"
    Then the response should be "404"
    And the error message should have "severity=error&exit_code=127"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML |   
     
  Scenario Outline: Delete domain of another user
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    Given a new guest account
    And I am a valid user
    When I send a DELETE request to "/domains/cucumber<random>"
    Then the response should be "404"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML |  
     
  Scenario Outline: Delete domain with existing applications
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber<random>/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber<random>"
    Then the response should be "400"
    And the error message should have "severity=error&exit_code=128"
    When I send a DELETE request to "/domains/cucumber<random>/applications/app"
    Then the response should be "204"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Force Delete domain with existing applications
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a POST request to "/domains/cucumber<random>/applications" with the following:"name=app&cartridge=php-5.3"
    Then the response should be "201"
    When I send a DELETE request to "/domains/cucumber<random>?force=true"
    Then the response should be "204"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Create more than one domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    And the response should be a "domain" with attributes "namespace=cucumber<random>"
    When I send a POST request to "/domains" with the following:"namespace=cucumberX<random>"
    Then the response should be "201"
    And the response should be a "domain" with attributes "namespace=cucumberX<random>"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 
     
  Scenario Outline: Create duplicate domain
    Given a new guest account
    And I am a valid user
    And I accept "<format>"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "201"
    When I send a POST request to "/domains" with the following:"namespace=cucumber<random>"
    Then the response should be "422"
    And the error message should have "field=namespace&severity=error&exit_code=103"
    
    Scenarios:
     | format | 
     | JSON | 
     | XML | 

    