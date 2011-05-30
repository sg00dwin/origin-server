@verify
Feature: Cucumber tests for reported bugs

  Scenario: (libra-qe) Bug 693951 - Command 'rhc-create-domain --alter' can not be used to rename domain
    Given an end user
    And he can create a namespace and app
    When he alters the namespace
    Then the new namespace is enabled

  Scenario: (libra-qe) Bug 700941 - Express client installation has empty README files under AppName/misc and AppName/libs
    Given the libra client tools
    When a new php-5.3 app 'phpbug' is created
    Then there is no README file under misc or libs

  Scenario: (libra-qe) Bug 699887 - PHP $_SERVER["HTTP_HOST"] returns wrong value
    Given the libra client tools
    When a new php-5.3 app 'phphost' is created
    Then the host name can be obtained using php script

  Scenario: (libra-qe) Bug 695586 - man page of express.conf is empty
    Given the libra client tools
    When the manpage of express.conf exists
    Then the manpage of express.conf should not be empty



