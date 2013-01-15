PEP: 1
Title: User Dunning and Forced Downgrades
Status: draft   
Author: Dan McPherson <dmcphers@redhat.com>  
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
  1) The users gears are stopped and deactivated
  2) After some configurable time period (TBD but think 6 months), the gears are destroyed.

Motivation
----------
Dunning/Downgrade is a requirement of a system that allows tiered levels of capabilities and ways for users to no longer be eligible for higher tiers.

OpenShift gets into this scenario in a couple of cases:

1) Users have gear usage above the free level and they do not pay their bill within a given grace period.
2) Users choose or are forced to downgrade to a lower tiered plan.  In most cases of downgrade by choice, users would reduce their own usage before downgrading.  But it's reasonably possible to allow a forced downgrade with the same process as dunning and might be necessary for some enterprise scenarios or online operational use cases.  Ex: Take a university using OpenShift for CS classes.  At the end of each semester (or as students graduate) they might want to cancel accounts but still give students some time to download their data.


Specification
-------------

Entering the Downgrade Process:
  Exit of the billing provider's dunning process in an arrears state is specified by an event from the billing provider (Aria).  When receiving the event, the users account will be marked as in_arrears (this logic must be transactional).  In the long term an event should be scheduled to take the user's account through the downgrade process.  In the short term we will want to manage the downgrade via a cron job similar to rhc-admin-ctl-usage --sync.  Let's refer to this as rhc-admin-ctl-plan --process-in-arrears.

User Downgrade:
  Detected by plan_state of in_arrears
  Loop across all the user's apps.
    - Change min scale to the min for the cart.  Scale down any existing scaled apps to their min.
    - Set gear state to deactivated.
    - Disable carts from starting.
    - Reduce storage?
    - Restrict shell access?
    - Restrict writes (have to allow delete still)?
  If the in_arrears plan
  plan_id is updated
  pending_plan_id is set to nil

User Destroy After Grace Period:
  After waiting for a reasonable time period (TBD) we will destroy any gears remaining for a user if they haven't managed to bring their assets into what the free plan allows.  We could leave assets in the amount of a free account but it's impossible to make a good choice of what gears to leave.  After the destroy of assets the user will be in the same position as a user in arrears who cleaned up their own gears down to the free level.
  
Reactivation After User Action :
  If users clean up their assets we need a way to bring them back online.  This case will also be handled by rhc-admin-ctl-plan --process-reactivations
  
Exiting an In Arrears State at a Later Date:
  If later the billing provider sends an event that a previously in arrears account has been resolved
  - If the downgrade had already occurred they would be eligible to sign up for a paid plan again.  After signing up for the upgraded plan again:
    - If their existing gears were deactivated, they can be reactivated.  The plan_state will be in left in a reactivating state in this scenario.  The activation will also need to be executed via a cron job until the scheduler exists (let's call it rhc-admin-ctl-plan --process-reactivations)
    - Else if they were deleted the user is the same a new user in a paid plan
  - Else the downgrade can be canceled and the user's pending_plan_id and plan_state restored.
  
Users in the Middle of the Dunning Process Grace Period:
  While the billing providers dunning process is ongoing no changes should happen to a user's assets.  They can continue to use OpenShift as they normally would.
  
Sub Accounts:
  Sub accounts are not handled by this design.
  
External Facing Code Changes:

Broker:
  - Cloud_User:
    plan_state: active*|deactivated|reactivating|in_arrears|pending

    The existing fields pending_plan_id and plan_id can be used to indicate a downgrade is necessary.  When pending_plan_id < plan_id a downgrade is required or in progress.
    
  - Users in a deactivated|in_arrears plan_state will not be allowed to create or control assets.
  - Existing plan states of active and pending need to be set properly on the user.
  

REST API:
  /user will also have the additional attribute of plan_state.

Runtime:
  Deactivate gear will be a new gear state with limited functionality and resources for a user accessing the gear.  Deactivate gear will be a mcollective call at the platform level.  Any restrictions we keep on deactivated gears need to be managed by the platform and not the carts.

Site:
  - The site will need to observe the in_arrears state (as indicated by Aria) on the user and disallow account upgrade.
  - The new user/gear state of deactivated will also need to be handled.  The user should be encouraged to get their usage down to the level of access they are currently granted.

Admin Tools:

  rhc-admin-ctl-plan --process-in-arrears  # Should be run on a frequency of at least once a day
    Loops through all users in arrears and processes forced downgrades and destroys.
  
  rhc-admin-ctl-plan --process-reactivations # Should be run on a frequency of ~ once an hour
    Loops through all users in reactivating state and reactivates existing assets
    Also loops through all users in a deactivated state and validates they are still out of bounds with their intended plan.

  rhc-admin-ctl-plan --process-in-arrears --login <login>
    Same as --process-in-arrears except for a single user
  
  rhc-admin-ctl-plan --process-reactivation --login <login>
    Same as --process-reactivations except for a single user

  rhc-admin-ctl-plan --change-plan <plan_name> --login <login> --force-downgrade
    Same as the force downgrade from --process-in-arrears except for a single user
  
  rhc-admin-ctl-plan --list-deactivated=<time period in days (Default: 180)>
    Lists the users/gears that have been deactivated for more than 6 months.


Backwards Compatibility
-----------------------
All changes are additive and backwards compatible.


Rationale
---------
*The technical rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other products.*

*The rationale should provide evidence of consensus within the community and discuss important objections or concerns raised during discussion.*
