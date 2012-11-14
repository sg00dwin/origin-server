@broker_api
@broker_api4
Feature: Application template list
  As an OpenShift user
  I should be able to preview the # of gears used by a quickstart based application
  So that I can quickly estimate how much it will cost.

  Scenario: Add a template and search for it by UUID
    Given a new user
    And I accept "XML"
    And there are no templates
    When I add a new template named 'Wordpress 1' with dependencies: 'php-5.3,mysql-5.1' and git repository 'git://github.com/openshift/wordpress-example.git' and tags 'php,mysql,wordpress' consuming 1 gear and metadata '{"foo" : "bar"}'
    And I search for the template UUID
    Then the response should be "200"
    And the template exists
    
  Scenario: Add a template and search for it by tag
    Given a new user
    And I accept "XML"
    And there are no templates
    When I add a new template named 'Wordpress 2' with dependencies: 'php-5.3,mysql-5.1,phpmyadmin-3.4' and git repository 'git://github.com/openshift/wordpress-example.git' and tags 'php,mysql,phpmyadmin,wordpress' consuming 1 gear and metadata '{"foo" : "bar"}'
    And I search for the tag 'phpmyadmin'
    Then the response should be "200"
    And the template should exist in list

  Scenario: Removing a template
    Given a new user
    And I accept "XML"
    And there are no templates
    When I add a new template named 'Wordpress 3' with dependencies: 'php-5.3,mysql-5.1' and git repository 'git://github.com/openshift/wordpress-example.git' and tags 'php,mysql,wordpress' consuming 1 gear and metadata '{"foo" : "bar"}'
    And I remove the template
    And I search for the template UUID
    Then the response should be "200"
    And the template should not exist in list
    
  Scenario: Add a template and create an application
    Given a new user
    And I accept "XML"
    And there are no templates
    When I add a new template named 'Wordpress 4' with dependencies: 'php-5.3,mysql-5.1' and git repository 'git://github.com/openshift/wordpress-example.git' and tags 'php,mysql,wordpress' consuming 1 gear and metadata '{"foo" : "bar"}'
    When I send a POST request to "/domains" with the following:"id=api<random>"
    Then the response should be "201"
    When I create a new application named 'fooapp' within domain 'api<random>' with the template
    Then the response should be "201"
    When I send a GET request to "/domains/api<random>/applications/fooapp"
    Then the response should be "200"
    When I send a DELETE request to "/domains/api<random>/applications/fooapp"
    Then the response should be "204"
    When I send a DELETE request to "/domains/api<random>"
    Then the response should be "204"

  Scenario: Test deploying a rails application and check if gem dependencies are resolved
    Given a new user
    And I accept "XML"
    And there are no templates
    When I add a new rails template
    And I search for the template UUID
    Then the response should be "200"
    And the template should exist in list
    When I send a POST request to "/domains" with the following:"id=api<random>"
    Then the response should be "201"
    When I create a new application named 'fooapp' within domain 'api<random>' with the template
    Then the response should be "201"
    And the application created from the template should be accessible
    When I send a DELETE request to "/domains/api<random>/applications/fooapp"
    Then the response should be "204"
    When I send a DELETE request to "/domains/api<random>"
    Then the response should be "204"
