@api
Feature: Application template list
  As an Openshift user
  I should be able to preview the # of gears used by a quickstart based application
  So that I can quickly estimate how much it will cost.

  Scenario: Add a template and search for it by UUID
	Given a new guest account
    And I am a valid user
    And I accept "XML"
	And there are no templates
	When I add a new template named 'Wordpress 1' with dependencies: 'php-5.3,mysql-5.1' and git repository 'git://github.com/openshift/wordpress-example.git' and tags 'php,mysql,wordpress' consuming 1 gear and metadata '{"foo" : "bar"}'
	And I search for the template UUID
	Then the response should be "200"
	And the template exists
	
  Scenario: Add a template and search for it by tag
	Given a new guest account
    And I am a valid user
    And I accept "XML"
    And there are no templates
	When I add a new template named 'Wordpress 2' with dependencies: 'php-5.3,mysql-5.1,phpmyadmin-3.4' and git repository 'git://github.com/openshift/wordpress-example.git' and tags 'php,mysql,phpmyadmin,wordpress' consuming 1 gear and metadata '{"foo" : "bar"}'
	And I search for the tag 'phpmyadmin'
	Then the response should be "200"
	And the template should exist in list

  Scenario: Removing a template
	Given a new guest account
    And I am a valid user
    And I accept "XML"
	And there are no templates
	When I add a new template named 'Wordpress 3' with dependencies: 'php-5.3,mysql-5.1' and git repository 'git://github.com/openshift/wordpress-example.git' and tags 'php,mysql,wordpress' consuming 1 gear and metadata '{"foo" : "bar"}'
	And I remove the template
	And I search for the template UUID
	Then the response should be "200"
	And the template should not exist in list