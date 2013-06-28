PEP: 1  
Title: User Dunning and Forced Downgrades  
Status: draft  
Author: Dan McPherson <dmcphers@redhat.com>, Lili Nader lnader@redhat.com   
Arch Priority: high  
Complexity: 40  
Affected Components: web, api, runtime, cartridges, broker, admin_tools, cli  
Affected Teams: Runtime (8), UI (8), Broker (21), Enterprise (5)  
User Impact: low  
Epic: 

Abstract
--------
Dunning is the process users enter when they neglect to pay their bill within a given grace period.  The end of the dunning cycle from a billing perspective results in a user account being downgraded or canceled.  There may also be other scenarios where a user downgrade requires the underlying system to bring the user's assets in line with the constraints of the downgraded plan.  In either case when a downgrade is necessary the following needs to occur:

If the user's assets are above the level the downgraded account allows: 
  1. The users applications are stopped and deactivated
  1. After some configurable time period (TBD but think 6 months), the applications are destroyed.

Motivation
----------
Dunning/Downgrade is a requirement of a system that allows tiered levels of capabilities and ways for users to no longer be eligible for higher tiers.

OpenShift gets into this scenario in a couple of cases:

1. Users have gear usage above the free level and they do not pay their bill within a given grace period.
1. Users choose or are forced to downgrade to a lower tiered plan.  In most cases of downgrade by choice, users would reduce their own usage before downgrading.  But it's reasonably possible to allow a forced downgrade with the same process as dunning and might be necessary for some enterprise scenarios or online operational use cases.  Ex: Take a university using OpenShift for CS classes.  At the end of each semester (or as students graduate) they might want to cancel accounts but still give students some time to download their data.


Specification
-------------

###Entering the Downgrade/Deactivation Process:
  Exit of the billing provider's dunning process in an arrears state is specified by an event from the billing provider (Aria).  When receiving the event, the user's account will be marked as canceled (this logic must be transactional) and pending_plan_id will be set to :free.  In the long term an event should be scheduled to take the user's account through the downgrade process.  In the short term we will want to manage the downgrade via a cron job similar to rhc-admin-ctl-usage --sync.  Let's refer to this as rhc-admin-ctl-plan --process-canceled.

###User Downgrade/Deactivation Process:
  + Detected by plan_state of canceled 
    + If the user assets are within the level of the pending_plan_id
      + Update user's plan to pending_plan_id
      + Set plan_state to active. pending_plan_id is set to nil
  
  
    + If current assets are above the level of the pending_plan_id
      + Loop across all the user's apps.
      + ~~Change min scale to the min for the cart.~~ requires changing the user application and cannot be reversed automatically after activation.
      + Scale down all applications to minimum number of gears. 
      + Stop all applications
      + Deactivate all gears for all applications [See detail][deactivate_gear]
      + Prevent user from creating new assets or controlling any existing ones. i.e. creating new applications, adding new cartridges or aliases to existing applications or running  commands like start/stop on application or cartridge. In other words they will be only able to view, limited update or delete their existing assets. Like, deleting applications, cartridges, removing SSL certs from aliases, updating cartridges to reduce storage or scaling.
      + Set plan_state to deactivated
      + plan_id remains as the user's original plan.  The pending_plan_id will remain as :free.
      
The downgrade/deactivation will be executed via a cron job until the scheduler exists (let's call it rhc-admin-ctl-plan --process-canceled)

###User Destroy After Grace Period:
  After waiting for a reasonable time period (TBD) we will destroy any gears remaining for a user if they haven't managed to bring their assets into what the free plan allows.  We could leave assets in the amount of a free account but it's impossible to make a good choice of what gears to leave.  After the destroy of assets the user will be in the same position as a user in arrears who cleaned up their own gears down to the free level.

### Entering the Reactivation process:
  Reactivation can be triggered by 2 events
   + If user brings their assets within the :free plan then they will be downgraded to :free plan and their applications will reactivated.
   + The billing provider sends an event that a previously in arrears account has been resolved. When receiving this event:
     + If plan_state is deactivated then the plan_state will be set to reactivating and pending_plan_id to the upgraded plan.
     + If the plan_state is canceled then the plan_state will be changed to active and pending_plan_id will be set to nil
     + If the plan_state is active or pending no changes will be made
     + If the user is deleted then the user is the same as a new user in a paid plan
     
### Available user action to bring assets within :free plan
  The user should be able to take the following actions while in the canceled or deactivated state in order to bring their assets down to the :free plan level
    + Delete domains, applications and cartridges
    + Remove private certificates
    + Reduce gear size
    + Reduce additional storage
   
### User Reactivation process:
  + Detected by plan_state of deactivated
    + If the user assets are within the level of the pending_plan_id
      + Loop across all user's app
      + reactivate all gears
      + Update user's plan to pending_plan_id
      + Set plan_state to active. pending_plan_id is set to nil
      
  + Detected by plan_state of reactivating
    + If the user assets are within the level of the pending_plan_id
      + Loop across all user's app
      + reactivate all gears
      + Update user's plan to pending_plan_id
      + Set plan_state to active. pending_plan_id is set to nil

The reactivation will also need to be executed via a cron job until the scheduler exists (let's call it rhc-admin-ctl-plan --process-reactivations)

  
###Users in the Middle of the Dunning Process Grace Period:
  While the billing providers dunning process is ongoing no changes should happen to a user's assets.  They can continue to use OpenShift as they normally would.
  
###Sub Accounts:
  Sub accounts are not handled by this design.
  
###External Facing Code Changes:

####Broker:
  - Cloud_User:
    plan_state: active*|deactivated|reactivating|canceled|pending
    The existing fields pending_plan_id and plan_id can be used to indicate a downgrade is necessary.  When pending_plan_id < plan_id a downgrade is required or in progress.
  - Application:
    new methods deactivate and reactivate
  - Enable user to change the gear size on an application (Future feature. For now user can must delete gears which do not match the plan)
  
####REST API:
  - User will also have the additional attribute of plan_state.
  - Users in a deactivated or canceled plan_state will not be allowed to create assets or control assets like restart application.
  - User should still be able to perform the following actions in order to bring their assets in line with the :free plan
    - Delete any assets
    - Update an existing alias to remove private certificate
    - Update a cartridge to remove additional storage
  - Provide an API for user to change the application gear size (Future feature. For now user must delete gears which do not match the plan)
  
####Runtime:
  - Gear deactivation is a configuration of the application container (gear):
    + Securely managed by the platform (node).
    + Designed to make the application unstartable and unusable.
    + Designed to allow application snapshot.
    + Designed to allow the gear owner to bring the application into compliance by removing assets.
    + Designed to allow complete platform API management except for start.
    + Entered into and exited from an mcollective call.
    + Once exited, the application should be able to return to a usable state.

  - Deactivation of a gear limits the CPU available to the gear.
    + Prevent subverting the purpose of deactivation.
    + CPU Quota is set to at most 5% of a CPU.
    + More stringent memory and nproc limits may interfere with snapshot.

  - Deactivation of a gear prevents the frontend http server from forwarding requests.
    + Removed from the idle list if it was idle.
    + The gear is added to a "disabled" list which causes the front-end to issue a "403 Forbidden" http response.

  - Deactivation of a gear will stop the gear and mark it as disabled.
    + The gear is stopped, the stop lock is created and its state is set to "stopped".
    + A ".disabled" file is created in the root of the gear, owned by root and is not removable or modifiable by the gear user.
    + All calls to build or start the gear or cartridges will be silently disabled.

  - Reactivation of the gear returns the gear to a stopped state
    + Resource limits are returned to normal.
    + The ".disabled" file is removed.
    + A gear may be started by the end-user or platform.

####Site:
  - The site will need to observe the in_arrears state (as indicated by Aria) on the user and disallow account upgrade.
  - The new user/applcation state of deactivated will also need to be handled.  The user should be encouraged to get their usage down to the level of access they are currently granted.

####CLI:
  - Needs to handle the new application state (:active, :deactivated) and user plan_state of canceled/deactivated.

####Admin Tools:

  rhc-admin-ctl-plan --process-canceled  # Should be run on a frequency of at least once a day
    Loops through all users in canceled plan_state and processes forced downgrades and deactivation.
  
  rhc-admin-ctl-plan --process-reactivations # Should be run on a frequency of ~ once an hour
    Loops through all users in reactivating state and reactivates existing assets
    Also loops through all users in a deactivated state and validates they are still out of bounds with their intended plan.

  rhc-admin-ctl-plan --process-canceled --login <login>
    Same as --process-canceled except for a single user
  
  rhc-admin-ctl-plan --process-reactivation --login <login>
    Same as --process-reactivations except for a single user

  rhc-admin-ctl-plan --change-plan <plan_name> --login <login> --force-downgrade
    Same as the force downgrade from --process-canceled except for a single user
  
  rhc-admin-ctl-plan --list-deactivated=<time period in days (Default: 180)>
    Lists the users/gears that have been deactivated for more than 6 months.


Backwards Compatibility
-----------------------
All changes are additive and backwards compatible.  Existing CLIs might not give first class messages about deactivated gears but reasonable messages should be returned from the nodes anyway.


Rationale
---------
The main debates here are over the business aspects of the logic rather than the technical details of how.  Namely, do we delete users immediately or after some grace period?  How long is the grace period?  Do we need long term storage even after we delete?
