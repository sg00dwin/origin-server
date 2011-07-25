@internals
Feature JBossAS Application

   Scenario: Create one JBoss AS Application
     Given an accepted node
     And a new guest account
     When I configure a jbossas application

And the guest account has no application installed
   Scenario: Delete one JBoss AS Application
     Given an accepted node
     And a new guest account
     And a new jbossas application
     When I deconfigure a jbossas application
     

   Scenario: Start a JBoss AS Application
     Given an accepted node
     And a new guest account
     And a new jbossas application
     And the jboss service is stopped
     When I start the jboss service


   Scenario: Stop a JBoss AS Application
     Given an accepted node
     And a new guest account
     And a new jbossas application
     And the jboss service is running
     When I stop the jboss service


   Scenario: Restart a JBoss AS Application
     Given an accepted node
     And a new guest account
     And a new jbossas application
     And the jboss service is running
     When I restart the jboss service
