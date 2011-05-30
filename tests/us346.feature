Feature: Rally User Story US346

  Scenario: Rack modification tests
    Given the libra client tools
    And the following test data
      | processes | users | apps |    type    |
      |     1     |   1   |  1   | rack-1.1 |
    When the applications are created
    Then they should all be accessible within 30 seconds
    Then users can create a new rails app using rails new
