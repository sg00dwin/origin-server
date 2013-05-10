PEP: 2  
Title: Online Integration with Aria billing provider  
Status: draft  
Author: Clayton Coleman <ccoleman@redhat.com>  
Arch Priority: high  
Complexity: 100 (implemented)  
Affected Components: web, api, runtime, cartridges, broker, admin_tools, cli  
Affected Teams: Runtime (1), UI (8), Broker (8), Enterprise (0)  
User Impact: high  
Epic:  

Abstract
--------

OpenShift Online will integrate with an external billing provider -- Aria -- to handle payments, usage charges, credit card transactions, billing, and tax and collection writing.  Aria provides a set of web APIs for performing user specific operations, and sends HTTPS messages back to OpenShift when specific end user events occur (time, account, or payment related).  Red Hat finance, legal, customer service, and operations all interact with the Aria administrative interface to provide account related aspects of the Aria system.


Motivation
----------

Given the complexity and risk of integrating Red Hat's primarily SKU/inventory model with OpenShift's usage based model at a core level, the business and engineering teams decided to contract an external vendor capable of handling the full stack of account related capabilities including billing, usage based billing, payments, tax collection, and reporting.  The OpenShift business and engineering teams solicited several bids which resulted in the selection of Aria as the primary vendor.

The design of the system is intended to be generic to billing providers where possible, and specific to Aria where speed of implementation is important.  OpenShift will integrate with Aria for a period of years, but OpenShift Onilne should remain capable of switching to another vendor.  A vendor change would be a major engineering effort and so the design does not attempt to minimize touch points on the Aria API.


Specification
-------------

The OpenShift broker and its Mongo data store are considered the system of record for all data specifically related to the OpenShift service and what a user may do.  The Aria system is considered the system of record for all billing, account, and payment related information.  The Red Hat Streamline service and attached internal IT servicesare considered the system of record for the user address, country, email, and customer service enablement.

### Parts of the System

Implementation of the payment and billing systems for OpenShift is divided into two areas:

* User account management - creation, payment selection, display of bills, selection of plans
* User capability enforcement - restricting the capabilities of a user based on their plan
* User usage reporting - identifying that a user has consumed a resource for a period of time and reporting that to Aria

#### Terms

* Plan
 * all users in OpenShift Online are assigned a plan, which is either 'free' or 'silver' at the time of this writing.  
 * A plan in the OpenShift data model is linked to a plan in the Aria system
 * The OpenShift plan defines capabilities which limit the scope of user actions
 * The Aria plan defines the rate schedule, tax characteristics, and financial characteristics of the capabilities provided by the OpenShift plan.

#### User account management

A user wishing to upgrade from their "free" (limited capability) plan to a paid plan must perform the following operations:

1.  Have a full Red Hat account, including a shipping address, country of origin, and email address
2.  Have an Aria account created for them in the Aria system to be the point of reference for all future transactions, including a billing address and valid email
3.  Provide a credit card payment method
4.  Select a valid plan to upgrade to.

All of these operations are managed in the OpenShift Online console interface.  Step 1 involves calls to the underlying Red Hat Streamline service (the system of record for user information).  Those are similar to calls made by the service today to handle account creation, user login, and user retrieval.  In step 2, the console makes remote HTTPS calls to the Aria system to establish a new user account.  In step 3, the user will submit their payment information directly to an Aria system - no credit card number ever passes through a Red Hat system.  After the success or failure of step 4, the user is redirected back to the OpenShift Online console.  In step 4, the OpenShift console makes a HTTPS API call to the OpenShift broker, which verifies the user has a valid, chargeable account, updates the local production database to indicate that the user is now on a new plan, and then makes a call to the Aria system to successfully upgrade their account.

After plan upgrade, the user can view their current accrued charges in the OpenShift Online console, view old bills, change their method of payment, change their billing address, or contact customer service.  All data retrieval calls are made from the console via HTTPS to the Aria system.  Some of this is cached in the OpenShift Online caching systems for a period of minutes or hours.  The full credit card information is never returned from Aria (beyond the last 4 digits and the cart type and expiration), but other data such as billing address, full name, and the info described above is.

#### User capability enforcement

OpenShift defines in its data model the concept of capabilities - a set of flags or other configuration values that limit what a user may do in the system.  Each user is assigned a set of capabilities when their account is created, and an OpenShift Online sysadmin may alter those capabilities at the request of the business.  In this system, users also have an assigned plan.  The plan has a set of override capabilities - when a user changes their plan those capabilities will be applied to their account.  Some example capabilities are:

- max_gears - the number of gears the user may have associated with their account
- gear_sizes - the types of gears a user may create applications with
- private_ssl_certificates - whether a user may assign a private SSL certificate to a custom domain (upsell feature of paid plans)

Capabilities are checked at the point of action.  If a user is currently using more gears than they are allowed, all requests that require the creation of a gear will fail.  If a user encounters a data integrity problem, it is possible to lack a capability, but for artifacts of the system to remain in place (gears above max_gears, private certificates assigned to applications).  OpenShift Online operations monitors and checks for those mismatches, and uses standard procedures to correct for those problems.

In general, hard limits within OpenShift related to user plans are enforced by capabilities within the OpenShift system.  No operation should fail because of an inability of the OpenShift system to communicate with the Aria system, EXCEPT plan upgrade and usage data reporting.  Capabilities are only changed by the operations team OR when the user changes their plan.

#### User usage reporting

The OpenShift system records the time and quantity of resources consumed by users into a transactional data store.  Usage is reported as a series of events (gear added, gear removed) along with a time.  At certain periods, the list of events is summarized into a bulk record for long term storage.  Barring system defects, all usage will be recorded in the transacitonal Mongo store as a consequence of user actions taken (the action and the usage record are transactional).  OpenShift Online uses a 3-node replicaset configuration - only catastrophic simultaneous loss of all three nodes and their attached storage could result in the loss of current usage data.

The stored records are communicated to Aria at 6 hour intervals via a bulk update process that sends a tranche of usage records for the users of the system via HTTPS to an Aria endpoint.  OpenShift and Aria share a checkpoint confirmation that ensures that all usage records are delivered.  System failures may present usage records from being sent for extended periods of time, but when the systems become available they will continue recording from the last accepted set.  Aria will process those logs and calculate charges based on the rate.  

##### Usage dispute resolution

In general, the OpenShift system will attempt to maintain perfect records of actual use.  Those records may be reported incorrectly to Aria, and settings in Aria may result in incorrect charges.  OpenShift will maintain enough data so that disputes of actual usage can be traced via audit from at least two sources - the Mongo datastore and a separate action log.

### Security Considerations

All OpenShift-Aria interactions EXCEPT the credit card direct post originate from the OpenShift console (web ui) or broker (data server) through HTTPS web calls.  Those calls pass directly from the originating server across the public internet to the Aria systems.  Aria uses a combination of an account wide API secret key (of length > 30 random characters) and a whitelisted IP range to validate incoming API requests.  All communication with Aria is over HTTPS with proper certificate checking.  Only the OpenShift Online server IPs are configured in Aria as acceptable incoming API request sources - those IPs map to the production systems that are allowed to make requests.

The credit card direct post is accomplished by having the user's browser send an HTML form POST directly to an Aria system.  The OpenShift console makes an API call prior to that POST to establish a unique secret session for the user.  The unique secret value is rendered to the page and included in the POST request.  Aria will reject the request if the secret is expired or does not match other information in the account.  The POST is made via HTTPS.  After the Aria system processes the request, it will redirect the user's browser back to a preconfigured OpenShift URL with a set of URL parameters that indicate success or failure (but do not contain user specific or card specific info).  There is no shared cookie or other form of cross server authentication.  Aria sets appropriate negative cache control headers on the result of the POST to prevent replay attacks.

Aria sends certain information to OpenShift over HTTPS when system events occur for users.  These events include rejected payments, the dunning process, and other customer service driven changes such as a refund or reestablishment of account status.  Those incoming HTTPS requests are made to the OpenShift Online broker and include a header containing the Aria API key, which is validated against our stored key to guarantee authenticity.

Compromise of the API key would require OpenShift Online to change local configuration files to rekey and a restart of the running processes.

OpenShift only stores the Aria account number per user, and the associated plan id - all other billing info is kept in Aria.  Only the last 4 digits of the credit card, the card type, and the card expiration date pass through the OpenShift console (and thus through the OpenShift security zone).  Billing information may pass through the OpenShift system and be logged to the OpenShift Online service logs - those logs are treated as secure information and only limited members of operations have access to them.

### Account state changes 

Users may elect to downgrade their account to a free plan.  To do so, they must deprovision most committed resources (gears and storage) until they are within the capabilities allowed by the free plan, but they do not need to deprovision resources that are essentially free (SSL support).  When they downgrade, their capabilities are restricted to the set of capabilities allocated to the free plan, and they will no longer be able to exceed those limits.  Any upsell features will be disabled.

See [PEP001: Dunning](https://github.com/openshift/li/blob/master/openshift-pep/private-openshift-pep-001.md) for information on the dunning process.


Backwards Compatibility
-----------------------

All changes are additive and backwards compatible.  OpenShift Online will provide specific implementations of generic hooks in the lower implementations, or add specific but empty hook points in the lower implementation.  All new APIs will be properly versioned.  OpenShift Origin will contain a generic implementation of plans and usage, with no actual implementation in place.  3rd parties may provide their own specific implementations via code.


Rationale
---------

TBD
