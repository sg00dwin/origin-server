%define htmldir %{_localstatedir}/www/html
%define sitedir %{_localstatedir}/www/libra/site

Summary:   Li site components
Name:      rhc-site
Version:   0.87.8
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-site-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires: js
BuildRequires: rubygem-coffee-script

Requires:  rhc-common
Requires:  rhc-server-common
Requires:  httpd
Requires:  mod_ssl
Requires:  mod_passenger
Requires:  ruby-geoip
Requires:  rubygem-passenger-native-libs
Requires:  rubygem-rails
Requires:  rubygem-json
Requires:  rubygem-parseconfig
Requires:  rubygem-xml-simple
Requires:  rubygem-formtastic
Requires:  rubygem-haml
Requires:  rubygem-recaptcha
Requires:  rubygem-hpricot
Requires:  rubygem-barista
Requires:  js
# The following requires are for the status subsite
Requires:  ruby-sqlite3
Requires:  rubygem-sqlite3
Requires:  rubygem-sinatra

BuildArch: noarch

%description
This contains the OpenShift website which manages user authentication,
authorization and also the workflows to request access.

%prep
%setup -q

%build
for x in `/bin/ls ./app/coffeescripts | /bin/grep \.coffee$ | /bin/sed 's/\.coffee$//'`
do
  file="./app/coffeescripts/$x.coffee"
  /usr/bin/ruby -e "require 'rubygems'; require 'coffee_script'; puts CoffeeScript.compile File.read('$file')" > ./public/javascripts/$x.js
done

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{sitedir}
cp -r . %{buildroot}%{sitedir}
ln -s %{sitedir}/public %{buildroot}%{htmldir}/app

mkdir -p %{buildroot}%{sitedir}/run
mkdir -p %{buildroot}%{sitedir}/log
mkdir -p -m 770 %{buildroot}%{sitedir}/tmp
touch %{buildroot}%{sitedir}/log/production.log

%clean
rm -rf %{buildroot}                                

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,root,libra_user) %{sitedir}/log/production.log
%config(noreplace) %{sitedir}/config/environments/production.rb
%{sitedir}
%{htmldir}/app

%post
/bin/touch %{sitedir}/log/production.log
chmod 0770 %{sitedir}/tmp

%changelog
* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.8-1
- Fixing site unit test to account for Bugz 797307 (kraman@gmail.com)
- make errors show up on the domain edit account page (johnp@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.7-1
- start selenium tests for new console (johnp@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Added cartridge related Rails stuff (ffranz@redhat.com)
- Test failure on def argument (ccoleman@redhat.com)
- Can't create keys until domain exists (ccoleman@redhat.com)
- Merge branch 'dev0227' (sgoodwin@redhat.com)
- new console specific styles (sgoodwin@redhat.com)
- Bug 795538 - not copying :content errors to :raw_content, hidden by bad unit
  tests (ccoleman@redhat.com)
- Keys controller test was building content incorrectly (ccoleman@redhat.com)
- changes addressing default list margin issues and moved a couple things from
  type to custom (sgoodwin@redhat.com)
- Use old layout for reset password, bug 797749 (ccoleman@redhat.com)
- cleanup all the old command usage in help and messages (dmcphers@redhat.com)

* Sun Feb 26 2012 Dan McPherson <dmcphers@redhat.com> 0.87.6-1
- 

* Sun Feb 26 2012 Dan McPherson <dmcphers@redhat.com> 0.87.5-1
- Add ribbon magic, start pulling variables out, realized that $gridGutterWidth
  is not constant in all responsive layouts. (ccoleman@redhat.com)
- Start using bootstrap styles, quick example of community markup from drupal
  (which can be changed), convert to SASS for navigation elements
  (ccoleman@redhat.com)
- Get ribbon perfected (ccoleman@redhat.com)
- Working prototype of community blog page (ccoleman@redhat.com)
- Merge branch 'dev/clayton/branding1' (ccoleman@redhat.com)
- More changes to community (ccoleman@redhat.com)
- Start prepping markup for community site (ccoleman@redhat.com)

* Sat Feb 25 2012 Dan McPherson <dmcphers@redhat.com> 0.87.4-1
- Log errors on test failure (ccoleman@redhat.com)
- Allow users to access new console in preview state (ccoleman@redhat.com)
- Fix tc_console failures, revert tc_signup.rb to see if we can trigger the
  failure again (ccoleman@redhat.com)
- Use absolute path on logo (ccoleman@redhat.com)
- Integrate sass-twitter-bootstrap temporarily (should be gem'd), begin moving
  override code out of _custom.scss and into variables and sections that mimic
  their origin (ccoleman@redhat.com)
- Bug 797270 is on Q/A.  Fix the test. (rmillner@redhat.com)
- Indentation was off by one space, causing build errors. (rmillner@redhat.com)
- Add preview message and links for the Management Console
  (ccoleman@redhat.com)
- Fixed location of applications partial (fotios@redhat.com)
- Merge branch 'master' into dev/clayton/app_tests (ccoleman@redhat.com)
- Added ability to status site to sync upon starting up (fotios@redhat.com)
- Functionals are running, errors are being returned, specific exceptions
  arechecked and thrown. (ccoleman@redhat.com)
- add obsoletes of old package (dmcphers@redhat.com)
- renaming jbossas7 (dmcphers@redhat.com)
- Handing application list over to ffranz (fotios@redhat.com)
- Helper to create shared domain object for test suite (ccoleman@redhat.com)
- Prevent infinite loop on bad server response - try rename only once
  (ccoleman@redhat.com)
- Removed RH proxy from the rest client source (ffranz@redhat.com)
- Added basic cartridge information to the app details page (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Merge branch 'master' into dev/clayton/app_tests (ccoleman@redhat.com)
- Server side validations (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Merge branch 'master' into dev/clayton/validation (ccoleman@redhat.com)
- Creation flow and key flow tests (ccoleman@redhat.com)
- minor style edits (sgoodwin@redhat.com)
- Update for jboss-as-7.1.0.Final (starksm64@gmail.com)
- Temporary commit to build (ffranz@redhat.com)
- Fixed several interface bugs (style and markup) (ffranz@redhat.com)
- Tests on server validation, local error handling (ccoleman@redhat.com)
- Removed that message from hell, embedded model of the rest api client
  (ffranz@redhat.com)
- Reverted production.rb (ffranz@redhat.com)
- Created ActiveResource structure for cartridges and embedded
  (ffranz@redhat.com)
- Add validation logic from server (ccoleman@redhat.com)
- Created ActiveResource structure for cartridges and embedded
  (ffranz@redhat.com)
- Temporary commit to build (ffranz@redhat.com)
- Added sqlite3 to Gemfile to correspond with site.spec (fotios@redhat.com)
- work with applications details page layout (johnp@redhat.com)
- Fix for BZ796812 (fotios@redhat.com)
- Revert Gemfile change (ccoleman@redhat.com)
- make the application title look better (johnp@redhat.com)
- Added top level content id (ccoleman@redhat.com)
- Fixed misaligned toolbar (ccoleman@redhat.com)
- Merge branch 'dev/clayton/loading' (ccoleman@redhat.com)
- Toolbar loading icon, correct styles in various forms (ccoleman@redhat.com)
- Add back button to application details page (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/loading (ccoleman@redhat.com)
- Loading tweaks (ccoleman@redhat.com)
- loader and styles for config app form (sgoodwin@redhat.com)
- Forms with loading, use form-inline where possible, disable form submit while
  submitting (ccoleman@redhat.com)
- Add sqlite-ruby to gemfile (ccoleman@redhat.com)
- make cancel button go back to the refering page (johnp@redhat.com)
- fix up application list layout a bit (johnp@redhat.com)
- revert to claytons styles (sgoodwin@redhat.com)
- Merge branch 'master' into dev/clayton/loading (ccoleman@redhat.com)
- Display loading content when form submit occurs (ccoleman@redhat.com)
- revert jboss 7.1 changes (dmcphers@redhat.com)
- quick fix to CSRF security bug (johnp@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- bug fixes (lnader@redhat.com)
- merge with my latest edits (sgoodwin@redhat.com)
- Update for jboss-as-7.1.0.Final (starksm64@gmail.com)
- Merge branch 'dev/clayton/header' (ccoleman@redhat.com)
- Make utility-nav drop below application list on small screens
  (ccoleman@redhat.com)
- Fix small device issues with footer (ccoleman@redhat.com)
- US1736: OpenShift status page (fotios@redhat.com)
- Reorder button in namespace section (ccoleman@redhat.com)
- More header tweaks via steve, fix not found error on Domain#edit
  (ccoleman@redhat.com)
- Removal of remaining :simple => true flags (ccoleman@redhat.com)
- Round one, transition console header (ccoleman@redhat.com)
- Update forms with back buttons, move :simple flag up into bootstrap form
  builder (ccoleman@redhat.com)
- Updates to forms to have better layout (ccoleman@redhat.com)
- Preparation for transitional styles, integrate fonts, fix weight to be normal
  (ccoleman@redhat.com)
- footer styles (sgoodwin@redhat.com)
- moved styleguide only styles to page level (sgoodwin@redhat.com)
- error thumbnail and defaul button edits (sgoodwin@redhat.com)
- Better unit tests for error handling, throw and log more detailed exception
  when server response is unexpected, and properly display composite errors on
  application creation page. (ccoleman@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.87.3-1
- add tests for the show application page (johnp@redhat.com)
- add tests for the applications list page (johnp@redhat.com)
- Text cleanup and form help (ccoleman@redhat.com)
- Use btn-mini, remove unused partial (ccoleman@redhat.com)
- Fix and update raw_content to be cleaner and fix bugs, some almost final
  styles (ccoleman@redhat.com)
- Saving with validation clears update_id (ccoleman@redhat.com)
- Add domains controller (ccoleman@redhat.com)
- Bug 795628 (ccoleman@redhat.com)
- set jboss version back for now (dmcphers@redhat.com)
- update jboss version (dmcphers@redhat.com)
- Cleanup of spacing, elements, names, and page titles (ccoleman@redhat.com)
- Merge branch 'dev/clayton/keys' (ccoleman@redhat.com)
- Fixup failing test (ccoleman@redhat.com)
- Overhaul of keys to work around existing defects (ccoleman@redhat.com)

* Mon Feb 20 2012 Dan McPherson <dmcphers@redhat.com> 0.87.2-1
- Styleguide should use split files (ccoleman@redhat.com)
- Pull out help links into their own helper URLs to minimize changes
  (ccoleman@redhat.com)
- Update my account with lost changes (ccoleman@redhat.com)
- Switch to split CSS files (ccoleman@redhat.com)
- Merge branch 'dev/clayton/units' (ccoleman@redhat.com)
- Split unit and integration tests for rest_api_test.rb (ccoleman@redhat.com)
- default bootstrap css (sgoodwin@redhat.com)
- customizations to bootstrap.css (sgoodwin@redhat.com)
- Unit test for 794764 (ccoleman@redhat.com)
- Fixes 794764: added Node.js to the list of standalone cartridges on website
  (ffranz@redhat.com)
- changes for US1797 (abhgupta@redhat.com)
- Remove puts (ccoleman@redhat.com)
- Update references to @application_type to work around issue with
  ActiveResource serialization for now (ccoleman@redhat.com)
- Use 'console' layout on User.show (ccoleman@redhat.com)
- Fixed bug 794643 by temporarily removing application_type getter
  (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/layouts (ccoleman@redhat.com)
- Fixes 794539: staging and production routes was redirecting the account
  creation to the control panel (ffranz@redhat.com)
- Tweak text (ccoleman@redhat.com)
- Add Node.js, remove version label and website (for now), and add :new marker
  (ccoleman@redhat.com)
- Add more aggressive guard to logging exceptions (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/layouts (ccoleman@redhat.com)
- <model>.first returns null if no items Fix domain name link for bug 790695
  (ccoleman@redhat.com)
- Add in more extensive key unit tests, fix a connection allocation bug, make
  unit tests reuse same user and teardown domain, fix layout of simple semantic
  forms, implement simple ssh key form for use within get_started
  (ccoleman@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.87.1-1
- bump spec numbers (dmcphers@redhat.com)
- Added contextual help on the app details page for the new console
  (ffranz@redhat.com)
- Added contextual help on the app details page for the new console
  (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixed errors that caused Sauce tests failures (ffranz@redhat.com)
- label style edits (sgoodwin@redhat.com)
- Merge branch 'dev2' (sgoodwin@redhat.com)
- edits for get started and other page styles (sgoodwin@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.86.9-1
- add style change to My Applications (johnp@redhat.com)
- allow mutable attrs to be added one at a time (johnp@redhat.com)

* Wed Feb 15 2012 Dan McPherson <dmcphers@redhat.com> 0.86.8-1
- restyle application list to new boostrap styles (johnp@redhat.com)
- bug 790635 (wdecoste@localhost.localdomain)
- add the config.base_domain var to all config files (johnp@redhat.com)
- Merge branch 'dev' (sgoodwin@redhat.com)
- style addtions for code pre and append-prepend (sgoodwin@redhat.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.86.7-1
- Developer fails at understanding core principles of coding
  (ccoleman@redhat.com)
- have rest api ActiveResource implement ActiveModel::Dirty (johnp@redhat.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.86.6-1
- Minor wording tweaks (ccoleman@redhat.com)
- Tweak rendering of domain name to make it more accurate (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/nextsteps (ccoleman@redhat.com)
- Flushed out getting started content (ccoleman@redhat.com)
- Merge branch 'dev' (sgoodwin@redhat.com)
- styleguide additions (sgoodwin@redhat.com)
- Merge branch 'master' into dev/clayton/nextsteps (ccoleman@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (ccoleman@redhat.com)
- Next steps page round #1 (ccoleman@redhat.com)
- .reload required to refresh .applications list (ccoleman@redhat.com)
- Improved app details page looking (ffranz@redhat.com)
- Merge branch 'dev0213' (sgoodwin@redhat.com)
- updates for create app fow (sgoodwin@redhat.com)
- Move types around (ccoleman@redhat.com)
- Further iteration on index views and confirm views, more railsisms and
  simplifications (ccoleman@redhat.com)
- Bug 790323 - consistent display of framework value (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- New console: added some more information to app details page
  (ffranz@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.5-1
- Disable broken tests for new REST API/Applications controller
  (aboone@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.4-1
- Replace print with Rails.logger.debug in PromoCodeMailer
  (ccoleman@redhat.com)
- Merge branch 'dev/clayton/wizards' (ccoleman@redhat.com)
- Make framework_name safer, throw ApplicationType::NotFound on errors
  (ccoleman@redhat.com)
- Fix a typo in site unit tests (aboone@redhat.com)
- Use bootstrap styles for select boxes Refactor filtering logic to be simpler
  and extract a model objec t Some railisms for naming of partials Added
  Application.framework_name which does a lookup on Applicat ionType to get the
  pretty name (ccoleman@redhat.com)
- hook up app filtering again and modify for rest api (johnp@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- New console: shows basic application info, dedicated application details page
  (ffranz@redhat.com)
- fix domain_delete test since we can't have more than one domain right now
  (johnp@redhat.com)
- messages doesn't exist on the application object anymore (johnp@redhat.com)
- fix custom_id for both nonmutable and mutable ids and add tests
  (johnp@redhat.com)
- add the destroy code for app deletion (johnp@redhat.com)
- Active state for clicking on the type elements (ccoleman@redhat.com)
- Move to 'wizard_steps' styles, fix chrome link clicking (with window.location
  = <> instead of jquery.trigger/click()) (ccoleman@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.3-1
- Allow application list to be shown with no domain (ccoleman@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (ccoleman@redhat.com)
- When dynamic loading occurs, exception for ActiveResource isn't loaded. In
  staging and production, the console/* and account/* urls should redirect to
  the control panel (ccoleman@redhat.com)
- Rescue ActiveResource errors and put their info in the rack env, also ensure
  no_info.html.haml is properly accessed (ccoleman@redhat.com)
- Merge branch 'dev/clayton/activeresource_clean' (ccoleman@redhat.com)
- Return after rendering (ccoleman@redhat.com)
- Flush out applications_controller#save (ccoleman@redhat.com)
- Flatten model structure for better Railsisms, rename unit test modules.
  (ccoleman@redhat.com)
- Unit tests pass, assignment is working (ccoleman@redhat.com)
- Refactoring out RestApi to have autoloading work for rails
  (ccoleman@redhat.com)
- Improve rendering and details of applications (ccoleman@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.2-1
- Fix for bug 788691 - show app deletion errors in the right place
  (aboone@redhat.com)
- Fix bug 789826 - restrict size of twitter avatars (aboone@redhat.com)
- Revert "require rest_api" - it seems this is reaking havok with tests
  (johnp@redhat.com)
- have the applications controller use the get_application API
  (johnp@redhat.com)
- add get_application convinience method to Domain (johnp@redhat.com)
- pass in options when instantiating a connection in find_single
  (johnp@redhat.com)
- require rest_api (johnp@redhat.com)
- hook up delete app again and port to active resources API (johnp@redhat.com)
- revamp styleguide (sgoodwin@redhat.com)
- Fix break in tests - no need for explicit requrie, and unit tests shouldn't
  be run from non-comand line includes (ccoleman@redhat.com)
- update to use new activecontroller APIs for showing data (johnp@redhat.com)
- add helper functions to the app model for getting the app's URLs
  (johnp@redhat.com)
- Bug 789281 - Explicitly set EXECJS_RUNTIME and disable barista autocompile
  (ccoleman@redhat.com)
- Tomporarily commenting out REST api tests on site (kraman@gmail.com)
- Create a new console controller which will route to applications (eventually
  we will have more complex flow here) (ccoleman@redhat.com)
- Integrate app creation workflow into new console (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/createapp (ccoleman@redhat.com)
- Update navigation with new application controller (ccoleman@redhat.com)
- Remove fixed position header CSS, handled flash[:success] messages correctly
  (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/bootstrap (ccoleman@redhat.com)
- Formtastic bootstrap markup is only enabled when before_filter :new_forms is
  defined Simple layout updated to be roughly consistent for now
  (ccoleman@redhat.com)
- Updated formtastic to get close to bootstrap (ccoleman@redhat.com)
- ordered list unstyled (sgoodwin@redhat.com)
- add the add an application link (johnp@redhat.com)
- Active Resource - allow toggling between integrated tests and mock tests
  (aboone@redhat.com)
- ActiveResource - fix create/update, other fixes (aboone@redhat.com)
- Reenable create link until it can be contextual (ccoleman@redhat.com)
- add application (johnp@redhat.com)
- implement delete app (johnp@redhat.com)
- add a delete button and confirm page (johnp@redhat.com)
- commit the filter template and add a flash message to index
  (johnp@redhat.com)
- make filters work (johnp@redhat.com)
- handle nil values (johnp@redhat.com)
- further filter additions (johnp@redhat.com)
- initial filter support (johnp@redhat.com)
- fix typo - point to app_list not app_info (johnp@redhat.com)
- make sure ApplicationsController is correctly defined (johnp@redhat.com)
- add the app list and info templates (johnp@redhat.com)
- added controller and route for console/applications (johnp@redhat.com)
- updated styleguide to use bootstrap (sgoodwin@redhat.com)
- General cleanup and refactoring of My Account and related forms to match new
  console layout Clean up flash presentation Begin investigating formtastic
  layout (ccoleman@redhat.com)
- Merge branch 'dev/sgoodwin/bootstrap' (sgoodwin@redhat.com)
- incorporate bootstrap (sgoodwin@redhat.com)
- Simple application type controller, layout, and default type population
  (ccoleman@redhat.com)
- Creating models for descriptor Fixing manifest files Added command to list
  installed cartridges and get descriptors (kraman@gmail.com)
- Revert "Added status subsite" (fotios@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (ccoleman@redhat.com)
- Fix streamline test (ccoleman@redhat.com)
- Removed test status db (fotios@redhat.com)
- Added status subsite (fotios@redhat.com)
- Merge branch 'dev/clayton/activeresource' (ccoleman@redhat.com)
- Comment out failing unit tests until bugs are fixed (ccoleman@redhat.com)
- Deserialize remote errors on 422 ResourceInvalid Delete properly passes
  requests down Expose 'login' as an alias to 'rhlogin' (ccoleman@redhat.com)
- Also use the SSH key display name in the edit form (aboone@redhat.com)
- Cleanup of names, better formatting, and inline doc (ccoleman@redhat.com)
- Add application, domain, and a backport of an activeresource association
  framework (ccoleman@redhat.com)
- fix bug 787079 with long ssh key names, also create and use @ssh_key.to_s
  method (aboone@redhat.com)
- Infrastructure for new layouts (ccoleman@redhat.com)
- Changed bootstrap css: responsive design improvements (ffranz@redhat.com)
- Initial support for retrieving user info (ccoleman@redhat.com)
- Remove openshift.rb, moved to rest_api.rb but bungled the merge
  (ccoleman@redhat.com)
- Merge branch 'dev/clayton/activeresource' of
  ssh://git1.ops.rhcloud.com/srv/git/li into dev/clayton/activeresource
  (ccoleman@redhat.com)
- More tests, make :as required, pass :as through, merge changes from upstream
  that simplify how the get{} connection method works (ccoleman@redhat.com)
- Add timeout of 3s for simple cases (ccoleman@redhat.com)
- Clarified names of SSH key attributes to match server (ccoleman@redhat.com)
- Able to make requests to server, next steps are serialization deserialization
  mapping for wierd backends (ccoleman@redhat.com)
- Expand authentication (ccoleman@redhat.com)
- More tests, able to hit server (ccoleman@redhat.com)
- Set cookie based on user object, pass user object to find / delete
  (ccoleman@redhat.com)
- Getting user aware connections working (ccoleman@redhat.com)
- Simple active resource ssh keys (ccoleman@redhat.com)
- Fix four failing unit tests (ccoleman@redhat.com)
- Merge branch 'dev/clayton/bootstrap' (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/my_account_latest
  (ccoleman@redhat.com)
- Clarified names of SSH key attributes to match server (ccoleman@redhat.com)
- Able to make requests to server, next steps are serialization deserialization
  mapping for wierd backends (ccoleman@redhat.com)
- Expand authentication (ccoleman@redhat.com)
- More tests, able to hit server (ccoleman@redhat.com)
- Set cookie based on user object, pass user object to find / delete
  (ccoleman@redhat.com)
- Getting user aware connections working (ccoleman@redhat.com)
- Simple active resource ssh keys (ccoleman@redhat.com)
- Updated to use styleguide instead of bootstrap for clarity, available via
  /app/styleguide (ccoleman@redhat.com)
- Workaround removed method (ccoleman@redhat.com)
- add a ssh success message to the en locale (johnp@redhat.com)
- display ssh key or edit box depending if it is set (johnp@redhat.com)
- correctly update ssh key (johnp@redhat.com)
- initial addition of sshkey updating (johnp@redhat.com)
- make work if ssh key is not yet set (johnp@redhat.com)
- keep sshkey if set when updating namespace, add start of ssh update
  (johnp@redhat.com)
- refactor edit to point to edit_namespace since we are adding edit_ssh
  (johnp@redhat.com)
- render flash messages on account page (johnp@redhat.com)
- use partial to render both create and update keys (johnp@redhat.com)
- [namespace update] stay on edit page on error and flash error message
  (johnp@redhat.com)
- make updating domains from accounts page work (johnp@redhat.com)
- initial edit namespace from accounts (johnp@redhat.com)
- Help link is correct Moved reset password to change password form
  (ccoleman@redhat.com)
- My account in mostly final form (ccoleman@redhat.com)
- All password behavior is functional (ccoleman@redhat.com)
- Use semantic_form_for on new password Provide ActiveModel like
  request_password_reset models Allow validation for :change_password and
  :reset_password scopes (ccoleman@redhat.com)
- Enable user model based change_password method in streamline Use
  semantic_form_tag in change password (ccoleman@redhat.com)
- Comment out path for now (ccoleman@redhat.com)
- More tweaking (ccoleman@redhat.com)
- Update routes to match older paths (ccoleman@redhat.com)
- Password controller unit tests (ccoleman@redhat.com)
- Remove warning in view (ccoleman@redhat.com)
- Tweaking layout of ssh_key to use semantic_form_tag (ccoleman@redhat.com)
- More experimentation with users (ccoleman@redhat.com)
- Restored changes for UserController.reset / request_reset
  (ccoleman@redhat.com)
- Changes to templates to experiment with help (ccoleman@redhat.com)
- Create new password controller, create new /account structure, add some
  simple helper forms for inline domain display.  Needs lots more testing but
  represents a simple my account.  Access via /app/account while authenticated.
  (ccoleman@redhat.com)
- Bootstrap controller (ccoleman@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.86.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Feb 02 2012 Dan McPherson <dmcphers@redhat.com> 0.85.15-1
- Properly pass ticket when adding/updating/deleting SSH keys
  (aboone@redhat.com)

* Wed Feb 01 2012 Dan McPherson <dmcphers@redhat.com> 0.85.14-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 785654: added horizontal scroll with overflow-x (ffranz@redhat.com)
- Fix an issue w/ SSH key deletion (aboone@redhat.com)
- Ensure additional SSH key is valid before attempting to persist (BZ 785867)
  (aboone@redhat.com)
- Fix display of SSH keys with long names (bugzilla 786382) (aboone@redhat.com)
- More agressively shorten invalid SSH key so it fits in error message
  (aboone@redhat.com)

* Tue Jan 31 2012 Dan McPherson <dmcphers@redhat.com> 0.85.13-1
- Adding a selenium test for SSH keys and a couple of markup tweaks to support
  it (aboone@redhat.com)
- Show default key as "default" instead of "Primary" on site (BZ 785953)
  (aboone@redhat.com)

* Mon Jan 30 2012 Dan McPherson <dmcphers@redhat.com> 0.85.12-1
- update json version (dmcphers@redhat.com)

* Mon Jan 30 2012 Dan McPherson <dmcphers@redhat.com> 0.85.11-1
- update treetop refs (dmcphers@redhat.com)

* Mon Jan 30 2012 Dan McPherson <dmcphers@redhat.com> 0.85.10-1
- Revert changes to development.log in site,broker,devenv spec
  (aboone@redhat.com)
- Reduce number of rubygem dependencies in site build (aboone@redhat.com)

* Sat Jan 28 2012 Dan McPherson <dmcphers@redhat.com> 0.85.9-1
- 

* Sat Jan 28 2012 Alex Boone <aboone@redhat.com> 0.85.8-1
- Site build - don't use bundler, install all gems via RPM (aboone@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.85.7-1
- POST to delete SSH keys instead of DELETE - browser compatibility
  (aboone@redhat.com)
- manage multiple SSH keys via the site control panel (aboone@redhat.com)
- Refactor ExpressApi to expose a class-level http_post method
  (aboone@redhat.com)
- Add a helper to generate URLs to the user guide for future topics
  (ccoleman@redhat.com)
- Another fix for build issue created in 532e0e8 (aboone@redhat.com)
- Fix for 532e0e8, also properly set permissions on logs (aboone@redhat.com)
- Remove therubyracer gem dependency, "js" is already being used
  (aboone@redhat.com)
- Unit tests all pass (ccoleman@redhat.com)
- Make streamline_mock support newer api methods (ccoleman@redhat.com)
- Streamline library changes (ccoleman@redhat.com)
- Provide barista dependencies at site build time (aboone@redhat.com)
- Add BuildRequires: rubygem-crack for site spec (aboone@redhat.com)
- remove old obsoletes (dmcphers@redhat.com)
- Consistently link to the Express Console via /app/control_panel
  (aboone@redhat.com)
- Allow app names up to 32 chars (fix BZ 784454) (aboone@redhat.com)
- remove generated javascript from git; generate during build
  (johnp@redhat.com)
- reflow popups if they are clipped by the document viewport (johnp@redhat.com)
- Fixed JS error 'body not defined' caused by previous commit
  (ccoleman@redhat.com)
- cleanup (dmcphers@redhat.com)

* Tue Jan 25 2012 John (J5) Palmieri <johnp@redhat.com> 0.85.6-1
- remove generated javascript and use rake to generate
  javascript during the build

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.5-1
- Remove floating header to reduce problems on iPad/iPhone
  (ccoleman@redhat.com)

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.4-1
- merge and ruby-1.8 prep (mmcgrath@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.85.3-1
- Fix documentation links (aboone@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- Adding Flex Monitoring and Scaling video for Chinese viewers
  (aboone@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- bump spec numbers (dmcphers@redhat.com)
- Adding China-hosted Flex - Deploying Seam video (BZ 773191)
  (aboone@redhat.com)
