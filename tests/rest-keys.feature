@api
Feature: keys
  As an API client
  In order to do things with keys
  I want to List, Create, Retrieve, Update and Delete keys
  
  Scenario: List keys
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a GET request to "/user/keys"
    Then the response should be "200"
    
  Scenario: Create key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123=567[dfhhfl]"
    Then the response should be "201"
    When I send a DELETE request to "/user/keys/cucumber"
    Then the response should be "204"
    
  Scenario: Retrieve key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123=567[dfhhfl]"
    Then the response should be "201"
    When I send a GET request to "/user/keys/cucumber"
    Then the response should be "200"
    When I send a DELETE request to "/user/keys/cucumber"
    Then the response should be "204"
  
  Scenario: Update key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123=567[dfhhfl]"
    Then the response should be "201"
    When I send a PUT request to "/user/keys/cucumber" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123=567[dfhhfl]1"
    Then the response should be "200"
    When I send a DELETE request to "/user/keys/cucumber1"
    Then the response should be "204"
    
  Scenario: Delete key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123=567[dfhhfl]"
    Then the response should be "201"
    When I send a DELETE request to "/user/keys/cucumber"
    Then the response should be "204"
    
  Scenario: Create duplicate key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123=567[dfhhfl]"
    Then the response should be "201"
    When I send a POST request to "/user/keys" with the following:"name=cucumber&type=ssh-rsa&content=XYZ123=567[dfhhfl]"
    Then the response should be "409"
    When I send a DELETE request to "/user/keys/cucumber"
    Then the response should be "204"
   
  Scenario: Retrieve non-exstent key
    Given a new guest account
    And I am a valid user
    And I accept "XML"
    When I send a GET request to "/user/keys/cucumber"
    Then the response should be "404"
    


    