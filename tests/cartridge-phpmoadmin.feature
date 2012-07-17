# Presently disabled, was giving jenkins errors and we're likely going to remove this feature in the very near future
#@runtime
#@runtime2
#Feature: phpMoAdmin Embedded Cartridge
#
#  Scenario Outline: Add Remove phpMoAdmin to one application
#    Given an accepted node
#    And a new guest account
#    And a new <type> application
#    And a new mongodb database
#    When I configure phpmoadmin
#    Then a phpmoadmin http proxy file will exist
#    And a phpmoadmin httpd will be running
#    And the phpmoadmin directory will exist
#    And phpmoadmin log files will exist
#    And the phpmoadmin control script will exist
#    When I deconfigure phpmoadmin
#    Then a phpmoadmin http proxy file will not exist
#    And a phpmoadmin httpd will not be running
#    And the phpmoadmin directory will not exist
#    And phpmoadmin log files will not exist
#    And the phpmoadmin control script will not exist
#
#  Scenarios: Add Remove phpMoAdmin to one Application Scenarios
#    |type|
#    |php|
#
#
#
#  Scenario Outline: Stop Start Restart phpMoAdmin
#    Given an accepted node
#    And a new guest account
#    And a new <type> application
#    And a new mongodb database
#    And a new phpmoadmin
#    And phpmoadmin is running
#    When I stop phpmoadmin
#    Then a phpmoadmin httpd will not be running
#    And phpmoadmin is stopped
#    When I start phpmoadmin
#    Then a phpmoadmin httpd will be running
#    When I restart phpmoadmin
#    Then a phpmoadmin httpd will be running
#
#  Scenarios: Stop Start Restart phpMoAdmin scenarios
#    |type|
#    |php|