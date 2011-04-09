@verify
Feature: Rally User Story us346

  Scenario: Rack modification tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   1   |  1   | rack-1.1.0 |
    When the applications are created
    Then they should all be accessible within 30 seconds
    Then users are able to create new rails app using rails new
