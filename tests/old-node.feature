@internals
Feature: Namespace Management
 Scenario: Delete One Namespace OLD
    Given an accepted node
    When I create a new namespace OLD
    And I make the REST call to delete the namespace
    Then a namespace should get deleted
