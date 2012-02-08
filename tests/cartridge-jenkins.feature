@internals
Feature: Jenkins Application

   Scenario: Create Delete one Jenkins Application
     Given an accepted node
     And a new guest account
     When I configure a jenkins application
     Then a jenkins application directory will exist
     And the jenkins application directory tree will be populated
     And a jenkins git repo will exist
     And the jenkins git hooks will exist
     And a jenkins source tree will exist
     #And the openshift environment variable files will exist
     And a jenkins service startup script will exist
     And a jenkins application http proxy file will exist
     And a jenkins application http proxy directory will exist
     And a jenkins daemon will be running
     And the jenkins daemon log files will exist
     When I deconfigure the jenkins application
     Then a jenkins application http proxy file will not exist
     Then a jenkins application directory will not exist
     And a jenkins git repo will not exist
     And a jenkins source tree will not exist
     #And the openshift environment variable files will not exist
     And a jenkins daemon will not be running     

   Scenario: Stop Start a Jenkins Application
     Given an accepted node
     And a new guest account
     And a new jenkins application
     And the jenkins service is running
     When I stop the jenkins service
     Then a jenkins daemon will not be running
     And the jenkins service is stopped
     When I start the jenkins service
     Then a jenkins daemon will be running
     And I deconfigure the jenkins application
     