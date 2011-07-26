@internals
Feature: JBossAS Application

   Scenario: Create one JBoss AS Application
     Given an accepted node
     And a new guest account
     When I configure a jbossas application
     Then a jbossas application directory will exist
     And the jbossas application directory tree will exist
     And the jbossas server and module files will exist
     And the jbossas server configuration files will exist
     And the jbossas standalone scripts will exist
     And a jbossas git repo will exist
     And the jbossas git hooks will exist
     And a jbossas deployments directory will exist
     And a jbossas service startup script will exist
     And a jbossas source tree will exist
     And a jbossas application http proxy file will exist
     And a jbossas daemon will be running

And the guest account has no application installed
   Scenario: Delete one JBoss AS Application
     Given an accepted node
     And a new guest account
     And a new jbossas application
     When I deconfigure the jbossas application
     

   Scenario: Start a JBoss AS Application
     Given an accepted node
     And a new guest account
     And a new jbossas application
     And the jbossas service is stopped
     When I start the jbossas service


   Scenario: Stop a JBoss AS Application
     Given an accepted node
     And a new guest account
     And a new jbossas application
     And the jbossas service is running
     When I stop the jbossas service


   Scenario: Restart a JBoss AS Application
     Given an accepted node
     And a new guest account
     And a new jbossas application
     And the jbossas service is running
     When I restart the jbossas service
