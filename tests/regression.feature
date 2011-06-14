@regression
Feature: Cucumber tests for reported bugs

  Scenario: (libra-qe) Bug 693951 - Command 'rhc-create-domain --alter' can not be used to rename domain
    Given an end user
    And he can create a namespace and app
    When he alters the namespace
    Then the new namespace is enabled

  Scenario: (libra-qe) Bug 699887 - PHP $_SERVER["HTTP_HOST"] returns wrong value
    Given the libra client tools
    When a new php-5.3 app 'phphost' is created
    Then the host name can be obtained using php script



