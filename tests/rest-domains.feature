@api
Feature: List domains
  As an API client
  In order to do things with domains
  I want to retrieve a list of domains
  
  Scenario: retreive all domains as XML
    Given I am a valid API user
    And I accept XML
    When I send a GET request for "/broker/rest/domains"
    Then the response should be "200"
    
  Scenario: retreive all domains as JSON
    Given I am a valid API user
    And I accept XML
    When I send a GET request for "/broker/rest/domains"
    Then the response should be "200"
    