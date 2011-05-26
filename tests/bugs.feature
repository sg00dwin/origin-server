@verify
Feature: cucumber tests for reported bugs

  #Bug 701676 covered by Scenario in  "userstory.feature: #US280 - TC19"

  Scenario: (libra-qe) Bug 693951 - rhc-create-domain suggests --alter can be used to rename domain
    Given an end user
    And he could create a namespace and app
    When he alter the namespace
    Then the new namespace is enabled

#  Scenario: (libra-qe) bug 701159: posting data with http instead of https
#    Given the following website links
#      |         uri          |  protocol  |
#      | /                    |    http    |
#      | /app                 |    http    |
#      | /app/getting_started |    http    |
#      | /app/user/new        |    http    |
#    Then come into an error when they are accessed

  Scenario: (libra-qe) Bug 700941 - Express client installation has empty README files under AppName/misc and AppName/libs
    Given the libra client tools
    When create a new php-5.3 app 'phpbug'
    Then no README under misc and libs

  Scenario: (libra-qe) Bug 699887 - PHP $_SERVER["HTTP_HOST"] returns wrong value
    Given the libra client tools
    When create a new php-5.3 app 'phphost'
    Then can get host name using php script

  Scenario: (libra-qe) Bug 695586 - man page of express.conf is empty
    Given the libra client tools
    When the manpage of express.conf exists
    Then the manpage of express.conf should not be empty



