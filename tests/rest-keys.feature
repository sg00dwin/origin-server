@api
Feature: keys
  As an API client
  In order to do things with keys
  I want to List, Create, Retrieve, Update and Delete keys
  
  Scenario: List keys
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a GET request to "/user/keys"
    Then the response should be "200"
    
  Scenario: Create key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123567"
    Then the response should be "201"

  Scenario: Create key with with blank, missing and invalid content
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123=567[dfhhfl]"
    Then the response should be "422"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content="
    Then the response should be "422"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa"
    Then the response should be "422"
    
  Scenario: Create key with with blank, missing and invalid name
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucum?*ber&type=ssh-rsa&content=XYZ123"
    Then the response should be "422"
    When I send a POST request to "/user/keys" with the following:"name=&type=ssh-rsa&content=XYZ123"
    Then the response should be "422"
    When I send a POST request to "/user/keys" with the following:"type=ssh-rsa&content=XYZ123"
    Then the response should be "422"
 
  Scenario: Create key with blank, missing and invalid type
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-xyz&content=XYZ123567"
    Then the response should be "422"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=&content=XYZ123567"
    Then the response should be "422"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&content=XYZ123567"
    Then the response should be "422"
    
  Scenario: Retrieve key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123"
    Then the response should be "201"
    When I send a GET request to "/user/keys/cucumber"
    Then the response should be "200"
  
  Scenario: Retrieve non-exstent key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a GET request to "/user/keys/cucumber"
    Then the response should be "404"
  
  Scenario: Update key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123"
    Then the response should be "201"
    When I send a PUT request to "/user/keys/cucumber" with the following:"type=ssh-rsa&content=ABC890"
    Then the response should be "200"
    
  Scenario: Update key with with blank, missing and invalid content
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123"
    Then the response should be "201"
    When I send a PUT request to "/user/keys/cucumber" with the following:"type=ssh-rsa&content="
    Then the response should be "422"
    When I send a PUT request to "/user/keys/cucumber" with the following:"type=ssh-rsa"
    Then the response should be "422"
    When I send a PUT request to "/user/keys/cucumber" with the following:"type=ssh-rsa&content=ABC8??#@@90"
    Then the response should be "422"
    
  Scenario: Update key with blank, missing and invalid type
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123"
    Then the response should be "201"
    When I send a PUT request to "/user/keys/cucumber" with the following:"type=&content=ABC890"
    Then the response should be "422"
    When I send a PUT request to "/user/keys/cucumber" with the following:"&content=ABC890"
    Then the response should be "422"
    When I send a PUT request to "/user/keys/cucumber" with the following:"type=ssh-abc&content=ABC890"
    Then the response should be "422"
    
  Scenario: Update non-existent key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a PUT request to "/user/keys/cucumber" with the following:"type=ssh-rsa&content=ABC890"
    Then the response should be "404"
    
  Scenario: Delete key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber1&type=ssh-rsa&content=XYZ123456"
    Then the response should be "201"
    When I send a DELETE request to "/user/keys/cucumber1"
    Then the response should be "204"
    
  Scenario: Delete last key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber1&type=ssh-rsa&content=XYZ123"
    Then the response should be "201"
    When I send a DELETE request to "/user/keys/cucumber1"
    Then the response should be "204"
    
  Scenario: Delete non-existent key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a DELETE request to "/user/keys/cucumber"
    Then the response should be "404"
    
  Scenario: Create duplicate key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/domains" with the following:"namespace=cucumber"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123"
    Then the response should be "409"

  
    


    