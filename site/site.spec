%define htmldir %{_localstatedir}/www/html
%define sitedir %{_localstatedir}/www/stickshift/site

Summary:   Li site components
Name:      rhc-site
Version: 0.98.7
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-site-%{version}.tar.gz
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

# Core dependencies to run the build steps
BuildRequires: rubygem-bundler
BuildRequires: rubygem-rake
BuildRequires: js
# Additional dependencies to satisfy the gems, listed in Gemfile order
BuildRequires: rubygem-rails
BuildRequires: rubygem-recaptcha
BuildRequires: rubygem-json
BuildRequires: rubygem-stomp
BuildRequires: rubygem-parseconfig
BuildRequires: rubygem-xml-simple
BuildRequires: rubygem-haml
BuildRequires: rubygem-compass
BuildRequires: rubygem-formtastic
BuildRequires: rubygem-rack
BuildRequires: rubygem-regin
BuildRequires: rubygem-httparty
BuildRequires: rubygem-rdiscount
BuildRequires: rubygem-webmock
BuildRequires: rubygem-barista
BuildRequires: rubygem-mocha
BuildRequires: rubygem-hpricot
BuildRequires: rubygem-sinatra
BuildRequires: rubygem-tilt
BuildRequires: rubygem-sqlite3
BuildRequires: rubygem-mail
BuildRequires: rubygem-treetop
BuildRequires: rubygem-net-http-persistent
BuildRequires: rubygem-wddx
BuildRequires: rubygem-rcov
BuildRequires: rubygem-ci_reporter
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
Requires:  rubygem-compass
Requires:  rubygem-recaptcha
Requires:  rubygem-hpricot
Requires:  rubygem-barista
Requires:  rubygem-httparty
Requires:  rubygem-rdiscount
Requires:  rubygem-webmock
Requires:  js
Requires:  ruby-sqlite3
Requires:  rubygem-sqlite3
Requires:  rubygem-sinatra
Requires:  rubygem-mail
Requires:  rubygem-treetop
Requires:  rubygem-net-http-persistent
Requires:  rubygem-wddx
Requires:  rubygem-rcov
Requires:  rubygem-ci_reporter
Requires:  rhc-site-static
BuildArch: noarch

%description
This contains the OpenShift website which manages user authentication,
authorization and also the workflows to request access.

%package static
Summary:   The static content for the OpenShift website
Requires: rhc-server-common

%description static
Static files that can be used even if the OpenShift site is not installed,
such as images, CSS, JavaScript, and HTML.

%prep
%setup -q

%build
bundle exec compass compile
rm -rf tmp/sass-cache
bundle exec rake barista:brew
rm log/development.log
mv -f tmp/javascripts/* public/javascripts/
mv -f tmp/stylesheets/* public/stylesheets/

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

%post
/bin/touch %{sitedir}/log/production.log

%files
%attr(0775,root,libra_user) %{sitedir}/app/subsites/status/db
%attr(0664,root,libra_user) %config(noreplace) %{sitedir}/app/subsites/status/db/status.sqlite3
%attr(0744,root,libra_user) %{sitedir}/app/subsites/status/rhc-outage
%attr(0770,root,libra_user) %{sitedir}/tmp
%attr(0666,root,libra_user) %{sitedir}/log/production.log

%defattr(0640,root,libra_user,0750)
%{sitedir}
%{htmldir}/app
%config(noreplace) %{sitedir}/config/environments/production.rb
%config(noreplace) %{sitedir}/app/subsites/status/config/hosts.yml
%exclude %{sitedir}/public
%exclude %{sitedir}/tmp/javascripts
%exclude %{sitedir}/tmp/stylesheets

%files static
%defattr(0640,root,libra_user,0750)
%{sitedir}/public

%changelog
* Mon Sep 10 2012 Troy Dawson <tdawson@redhat.com> 0.98.7-1
- 

* Mon Sep 10 2012 Troy Dawson <tdawson@redhat.com> 0.98.6-1
- Merge pull request #353 from
  smarterclayton/bug849950_ensure_cart_tags_properly_pulled_from_server
  (openshift+bot@redhat.com)
- Backport changes from the opensource branch that fix build issues
  (ccoleman@redhat.com)
- Bug 849950 - Respect server tags (ccoleman@redhat.com)
- Bug 849950 - Give Zend cart proper metadata and ensure sorting of cartridges
  on the cartridge page is working. (ccoleman@redhat.com)

* Fri Sep 07 2012 Adam Miller <admiller@redhat.com> 0.98.5-1
- Merge pull request #350 from sg00dwin/master (openshift+bot@redhat.com)
- Merge pull request #340 from pravisankar/dev/ravi/zend-fix-description
  (openshift+bot@redhat.com)
- Merge branch 'master' of github.com:openshift/li (sgoodwin@redhat.com)
- add table-fixed class for IE text-overflow bug on sshkey table. Include form
  field states back in _custom (not sure why they don't work in _forms)
  (sgoodwin@redhat.com)
- BZ 849782 - rss button rendering issue BZ 839242 - new app page for zend
  needed css added BZ 820086 - long sshkey name text-overflow issue Check in
  new account plan styleguide pages for billing, payment, review/confirm along
  with new form validation css Misc css - switch heading font-size to be based
  off of $baseFontSize computation - match <legend> style to heading.divide for
  consistency when used on console form pages - addition of <select> to
  standard form field rules (not sure why they aren't included in bootstrap by
  default) - set box-showdow(none) on .btn so there's no conflict when used on
  <input> - create aside rule within console/_core to be used on pages with for
  secondary column (help) - remove input grid system rules that caused
  conflicting widths with inputs set to grid span - add :focus to
  buttonBackground mixin - decrease spacing associated with .control-group -
  added rules for :focus:required:valid :focus:required:invalid to take
  advantage of client side browsers that support them - move rules for field
  feedback states from _custom to _forms - .alert a so link color is optimal on
  all alert states (sgoodwin@redhat.com)
- Modify Display-name/Description fields for all cartridges (rpenta@redhat.com)

* Thu Sep 06 2012 Adam Miller <admiller@redhat.com> 0.98.4-1
- Merge pull request #343 from spurtell/spurtell/analytics
  (openshift+bot@redhat.com)
- updated sitespeedsample rate, updated origin download tracking, updated
  kissinsights code (spurtell@redhat.com)
- Merge branch 'master' of github.com:openshift/li (sgoodwin@redhat.com)
- Chrome bug fix 851389. Target Chrome and adjust span-flush-right to allow for
  width variance at grid spans widths within 768-980 (sgoodwin@redhat.com)

* Tue Sep 04 2012 Adam Miller <admiller@redhat.com> 0.98.3-1
- Added some functional tests around plan upgrades (hripps@redhat.com)

* Thu Aug 30 2012 Adam Miller <admiller@redhat.com> 0.98.2-1
- TA2740 Added form validation for payment, billing & technical account info
  (hripps@redhat.com)
- Merge pull request #325 from nhr/TA2734 (openshift+bot@redhat.com)
- Bug 849627 - In development mode, the Enter payment method form would hide
  errors. (ccoleman@redhat.com)
- Cloned the console layout & theme for use with accounts (hripps@redhat.com)
- Move console scss completely into partials so that it can be reused.
  (ccoleman@redhat.com)
- Use .name because aria_plan is protected (ccoleman@redhat.com)
- Add thread timeout safety to the async_aware gem method, and a test.  This
  fixes intermittent test failures with account dashboard (5s join timeout
  before).  Default timeout is now 15s. Also fix cases with parallel test
  cleanup (domain is stomping on other domains). (ccoleman@redhat.com)
- Merge pull request #298 from sg00dwin/master (openshift+bot@redhat.com)
- 849902 fix pricing page to display example site boxes correctly at mobile
  sizes (sgoodwin@redhat.com)

* Wed Aug 22 2012 Adam Miller <admiller@redhat.com> 0.98.1-1
- bump_minor_versions for sprint 17 (admiller@redhat.com)

* Wed Aug 22 2012 Adam Miller <admiller@redhat.com> 0.97.12-1
- Un-refactoring overwrite_db (fotios@redhat.com)
- Moved dumping to JSON to its own function (fotios@redhat.com)
- Moved deletion to its own function (fotios@redhat.com)
- Refuse to push if there are no Issues on this host (fotios@redhat.com)
- Added function to clear current database (useful for testing)
  (fotios@redhat.com)
- Refuse to sync from a host with no issues (fotios@redhat.com)
- Renamed sync to push (fotios@redhat.com)
- Moved writing database to helper functions (fotios@redhat.com)
- Merge pull request #283 from
  smarterclayton/bug849939_plan_upgrade_fails_to_put (openshift+bot@redhat.com)
- Bug 849939 - Use POST instead of PUT when submitting an account upgrade.
  (ccoleman@redhat.com)

* Tue Aug 21 2012 Adam Miller <admiller@redhat.com> 0.97.11-1
- Merge pull request #279 from
  smarterclayton/bug849627_improve_error_message_handling_on_direct_post
  (openshift+bot@redhat.com)
- ctl usage tests (dmcphers@redhat.com)
- Bug 849627 When an error is encountered from direct post, redirect back to
  the form with the error keys and attributes. (ccoleman@redhat.com)
- Merge pull request #276 from nhr/US2457_revised_billing_plan_layout
  (openshift+bot@redhat.com)
- Revised plan-related CSS; moved to .haml file (hripps@redhat.com)
- US2457 Updated plan layout to match latest design (hripps@redhat.com)

* Mon Aug 20 2012 Adam Miller <admiller@redhat.com> 0.97.10-1
- Merge pull request #275 from
  smarterclayton/bug849631_downgrade_should_show_errors
  (openshift+bot@redhat.com)
- No wizard state on plan selection page. (ccoleman@redhat.com)
- Bug 849631 - Downgrade of user plan should display errors to user
  (ccoleman@redhat.com)
- Bug 849636 Account upgrade should display validation messages from forms
  (ccoleman@redhat.com)
- Bug 849356 - The first two segments of the raw content for an SSH key should
  be used as type and content. (ccoleman@redhat.com)
- Merge pull request #251 from smarterclayton/header_and_footer_updates
  (openshift+bot@redhat.com)
- Tests were looking for old link name.  Moved newsletter into footer.
  (ccoleman@redhat.com)
- Update header and footer to fix doc links, and begin simplification of the
  header. (ccoleman@redhat.com)

* Fri Aug 17 2012 Adam Miller <admiller@redhat.com> 0.97.9-1
- Merge pull request #255 from
  smarterclayton/bug849068_warn_about_account_change (openshift+bot@redhat.com)
- Merge pull request #253 from nhr/US2457_auth_changes
  (openshift+bot@redhat.com)
- Add left margin to blog author image to force H1 to wrap
  (ccoleman@redhat.com)
- Bug 849068 - Warn the user when they take an action that may result in them
  being authenticated as another person. (ccoleman@redhat.com)
- US2457 Relaxed auth for cartridge types and app templates (nhr@redhat.com)

* Fri Aug 17 2012 Adam Miller <admiller@redhat.com> 0.97.8-1
- Merge pull request #249 from smarterclayton/support_aria_feature_flag
  (openshift+bot@redhat.com)
- Merge pull request #248 from fabianofranz/master (openshift+bot@redhat.com)
- Forgot to add plan info page for disabled path (ccoleman@redhat.com)
- Provide Aria enabled and disabled modes in production. (ccoleman@redhat.com)
- US2592 and US2583 (ffranz@redhat.com)

* Thu Aug 16 2012 Adam Miller <admiller@redhat.com> 0.97.7-1
- Merge pull request #230 from nhr/plan_tests (openshift+bot@redhat.com)
- US2457 - Added tests for billing components (nhr@redhat.com)

* Thu Aug 16 2012 Adam Miller <admiller@redhat.com> 0.97.6-1
- Merge pull request #237 from smarterclayton/add_process_id_to_rails_logs
  (openshift+bot@redhat.com)
- Merge pull request #226 from smarterclayton/us2516_fill_out_billing_flow
  (openshift+bot@redhat.com)
- Merge pull request #238 from smarterclayton/use_aria_proxy_for_devenv
  (openshift+bot@redhat.com)
- Create a separate test configuration for direct post so it does not conflict
  with the real values. (ccoleman@redhat.com)
- Add process id output to Rails loggers in all modes.  Will need to be changed
  in Rails 3.2+ (ccoleman@redhat.com)
- Point site and broker development environments to the Aria API proxy machine
  (same as streamline) (ccoleman@redhat.com)
- MasterPlan is cached without loading aria_plan, but the cached object is
  frozen which prevents the plan from being loaded. (ccoleman@redhat.com)
- Bad merge (ccoleman@redhat.com)
- Tweak cache_method for Plan to work correctly (ccoleman@redhat.com)
- PlansController#show should be auth protected (ccoleman@redhat.com)
- Overlapping cache responses because of key generation (ccoleman@redhat.com)
- REST API models were not inheriting parent state, which prevented caching
  from working.  Add caching more aggressively to all static content.  Remove
  singleton on application template. (ccoleman@redhat.com)
- US2516 Flush out the billing flow, add prototypical dashboard for plans, and
  add Aria caching. (ccoleman@redhat.com)

* Wed Aug 15 2012 Adam Miller <admiller@redhat.com> 0.97.5-1
- Merge pull request #231 from sg00dwin/master (openshift+bot@redhat.com)
- Styles and images for the developers technology page; and fix search field
  img on console/help, set new app input width (sgoodwin@redhat.com)
- Merge branch 'master' of github.com:openshift/li (sgoodwin@redhat.com)

* Tue Aug 14 2012 Adam Miller <admiller@redhat.com> 0.97.4-1
- Bug 847147 - Change linking of help information about SSH to the developer
  center, also add some informative help to the ssh upload section.
  (ccoleman@redhat.com)
- Made some minor changes based on code review (nhr@redhat.com)
- Added conditional display hints to plans (nhr@redhat.com)
- Updated plan selection page (nhr@redhat.com)
- Updated from comments (nhr@redhat.com)
- Merge remote-tracking branch 'upstream/master' into aria (nhr@redhat.com)
- Merge pull request #211 from fabianofranz/master (openshift+bot@redhat.com)
- Updated Plan, added Aria::MasterPlan (nhr@redhat.com)
- US2583: added and adjusted tests (ffranz@redhat.com)
- US2583: changed footer links and added redirects for the Legal content
  (ffranz@redhat.com)

* Thu Aug 09 2012 Adam Miller <admiller@redhat.com> 0.97.3-1
- Merge pull request #206 from smarterclayton/us2583_move_learn_more_to_drupal
  (openshift+bot@redhat.com)
- Remove unused code, add tests to cover new redirections (ccoleman@redhat.com)
- Move remaining openshift content in drupal (ccoleman@redhat.com)
- Merge pull request #199 from sg00dwin/master (openshift+bot@redhat.com)
- Point learn more to community (ccoleman@redhat.com)
- Merge pull request #194 from smarterclayton/direct_post_config_tasks
  (openshift+bot@redhat.com)
- fix blog author photo 829774 (sgoodwin@redhat.com)
- Middle initial is not serialized identically between create/update account.
  (ccoleman@redhat.com)
- Check persistence in unit tests (ccoleman@redhat.com)
- Update account upgrade edit page to more closely resemble emily's mockups and
  to reuse data (ccoleman@redhat.com)
- The mother of all integration tests (ccoleman@redhat.com)
- Flush out payment methods (ccoleman@redhat.com)
- Adding feature request search field (sgoodwin@redhat.com)
- Add direct payment edit paths, simplify logic and flow (ccoleman@redhat.com)
- Provide rake tasks to set/clear direct post Aria configuration.
  (ccoleman@redhat.com)
- Remove ruby common code from rhc-server-common (ccoleman@redhat.com)

* Thu Aug 02 2012 Adam Miller <admiller@redhat.com> 0.97.2-1
- Merge pull request #162 from smarterclayton/use_ci_reporter_in_site
  (ccoleman@redhat.com)
- Bug 844845 - Parallelize site tests, add junit style XML output for reporting
  to Jenkins (ccoleman@redhat.com)

* Thu Aug 02 2012 Adam Miller <admiller@redhat.com> 0.97.1-1
- bump_minor_versions for sprint 16 (admiller@redhat.com)

* Wed Aug 01 2012 Adam Miller <admiller@redhat.com> 0.96.8-1
- css fix for 844916b (sgoodwin@redhat.com)
- fix 844891 (sgoodwin@redhat.com)

* Tue Jul 31 2012 Adam Miller <admiller@redhat.com> 0.96.7-1
- add custom forum only search; minor work of breadcrumb partials and spacing,
  headings at <480px get small line-height (sgoodwin@redhat.com)
- Merge pull request #151 from
  smarterclayton/bug844231_user_gets_error_on_signup (contact@fabianofranz.com)
- Merge pull request #150 from smarterclayton/captcha_can_be_nil
  (contact@fabianofranz.com)
- Merge pull request #145 from
  smarterclayton/us2531_add_user_agent_to_console_requests
  (ccoleman@redhat.com)
- Bug 844231 - During signup, a user who has confirmed his email sees an error
  message, instead of being taken to the signup confirm page.  This is because
  streamline has different behavior if the user has confirmed their email.
  (ccoleman@redhat.com)
- Allow captcha to be set to nil to disable it. (ccoleman@redhat.com)
- Fix functional tests (ccoleman@redhat.com)
- Send a consistent user agent from the console to Aria, Streamline, and
  broker. (ccoleman@redhat.com)

* Mon Jul 30 2012 Dan McPherson <dmcphers@redhat.com> 0.96.6-1
- Merge pull request #89 from smarterclayton/add_tax_exempt_model_attribute
  (ccoleman@redhat.com)
- Remove tax exemption for simplification of process. (ccoleman@redhat.com)
- Have account_upgrade completion post to itself to simplify creation, move
  some plan stuff, update tests to validate plan id from broker.
  (ccoleman@redhat.com)
- Ensure that the correct plan ID is pushed to the user object.
  (ccoleman@redhat.com)
- Add the necessary glue so that the checkbox for tax exemption shows up and
  sets values on creation.  Also ensure that user accounts are created with the
  default tax_exempt value of 0. (ccoleman@redhat.com)
- Add a tax_exempt supplemental attribute in Aria for use by Ops team.  Value 0
  means not tax exempt, value 1 means has requested exemption, value 2 means
  user has been confirmed exempt (ccoleman@redhat.com)

* Thu Jul 26 2012 Dan McPherson <dmcphers@redhat.com> 0.96.5-1
- site.spec: removing release changes (tdawson@redhat.com)
- site.spec: clean up the spec file (tdawson@redhat.com)
- add requires for rhc-site-static (dmcphers@redhat.com)

* Thu Jul 19 2012 Adam Miller <admiller@redhat.com> 0.96.4-1
- added rubygem-rcov to Build/Requires for site to fix brew build breakage
  (admiller@redhat.com)

* Thu Jul 19 2012 Adam Miller <admiller@redhat.com> 0.96.3-1
- Merge remote-tracking branch 'origin/master' into move_os-client-tools_to_rhc
  (ccoleman@redhat.com)
- Removed invalid puts (ccoleman@redhat.com)
- Move %%files static below %%post, give all static files the default
  permissions (ccoleman@redhat.com)
- Merge pull request #85 from smarterclayton/us2518_split_rpm_output_of_site
  (contact@fabianofranz.com)
- Merge pull request #68 from J5/master (ccoleman@redhat.com)
- Add console layout helpers for steve's story (ccoleman@redhat.com)
- Merge pull request #67 from sg00dwin/master (ccoleman@redhat.com)
- Provide a rake task to delete pregenerated content in a devenv.  Run rake
  assets:clean to make autogeneration work. (ccoleman@redhat.com)
- US2518 - Split the RPM output of the site into a static subpackage that can
  be installed and updated independently. (ccoleman@redhat.com)
- Merge pull request #77 from smarterclayton/add_test_suite_tasks
  (ccoleman@redhat.com)
- US2531 - Move os-client-tools to rhc (ccoleman@redhat.com)
- Fix remaining issue with mock reuse (wrapper class doesn't pass
  http_without_mock to nested connection) (ccoleman@redhat.com)
- Speed up tests by reswizzling http mock behavior (ccoleman@redhat.com)
- refactor "rcov" rake task to "coverage" (johnp@redhat.com)
- add rcov rake task for site (johnp@redhat.com)
- Add new rake test:streamline, test:aria, and test:restapi wrappers for more
  focused testing (ccoleman@redhat.com)
- switch margin to baseLineHeight variable (sgoodwin@redhat.com)
- Merge branch 'master' of github.com:openshift/li (sgoodwin@redhat.com)
- revert class placement (sgoodwin@redhat.com)
- switch to baseLineHeight (sgoodwin@redhat.com)
- Visual adjustments several places (sgoodwin@redhat.com)

* Fri Jul 13 2012 Adam Miller <admiller@redhat.com> 0.96.2-1
- Streamline fixed the confirm email bug in staging so that confirm can be done
  twice. (ccoleman@redhat.com)
- Merge pull request #65 from
  smarterclayton/bug_839545_duplicate_text_in_template (ccoleman@redhat.com)
- Bug 839545 - The provides element on a template should be coerced to an array
  (ccoleman@redhat.com)
- Merge pull request #60 from
  smarterclayton/bug_839127_update_client_install_docs (ccoleman@redhat.com)
- Merge pull request #59 from nhr/BZ838062r1 (ccoleman@redhat.com)
- Bug 839127 - Update the client getting started documentation to be more gem
  centric (cross platform) and link out to a new developer center page.
  (ccoleman@redhat.com)
- Building controller now differentiates between Jenkins server DNS delays and
  other Jenkins client cartridge creation errors. Also revised/streamlined
  cartridge save attempt logic (nhr@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.96.1-1
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.95.13-1
- Add more tests to verify filtering and behavior of application template
  methods and make the filtering apply after the objects have been type
  converted (ccoleman@redhat.com)
- Allow templates to be added which do not show up in production (the
  :in_development / 'in_development' category/tag) (ccoleman@redhat.com)
- Add an integration test specifically for the Streamline confirm twice failure
  and rescue body errors so the ticket can be retrieved (ccoleman@redhat.com)
- Merge pull request #50 from sg00dwin/master (ccoleman@redhat.com)
- Merge branch 'master' of github.com:openshift/li (sgoodwin@redhat.com)
- Visual edits and bug fix (sgoodwin@redhat.com)
- merge into one file for _code.scss (sgoodwin@redhat.com)

* Tue Jul 10 2012 Adam Miller <admiller@redhat.com> 0.95.12-1
- Add tests to streamline to ensure parse failures are handled.
  (ccoleman@redhat.com)
- Merge pull request #51 from fabianofranz/master (ccoleman@redhat.com)
- Bug 838800 - Update streamline address in drupal, make no cookies the default
  (ccoleman@redhat.com)
- Updated links to pricing page to point to full url (contact@fabianofranz.com)
- Links to pricing page all over the website, related to BZ 837902
  (contact@fabianofranz.com)
- Merge pull request #46 from smarterclayton/aria_payment_methods
  (ccoleman@redhat.com)
- Get unit tests passing again (ccoleman@redhat.com)
- Implement account payment specification and full account creation flow
  (ccoleman@redhat.com)

* Mon Jul 09 2012 Adam Miller <admiller@redhat.com> 0.95.11-1
- Fix ordering test to be accurate with 1.8 ruby now lower.
  (ccoleman@redhat.com)
- Update Ruby 1.8.7 to fall further down the list, fix double HTML escaping of
  descriptions (ccoleman@redhat.com)
- Ensure cart metadata is not overwriting core values. (ccoleman@redhat.com)

* Mon Jul 09 2012 Dan McPherson <dmcphers@redhat.com> 0.95.10-1
- 

* Mon Jul 09 2012 Dan McPherson <dmcphers@redhat.com> 0.95.9-1
- Merge pull request #40 from
  smarterclayton/bugz_838428_users_intermittently_logged_out
  (ccoleman@redhat.com)
- Fix bug 838428 and random session logout issues caused by the session cookie
  being unencoded. (ccoleman@redhat.com)

* Mon Jul 09 2012 Dan McPherson <dmcphers@redhat.com> 0.95.8-1
- Merge pull request #36 from
  smarterclayton/bugz_814025_prevent_external_redirect (ccoleman@redhat.com)
- Merge branch 'sgoodwin-dev0506' (sgoodwin@redhat.com)
- Multiple style related changes to address bugs or other issue
  (sgoodwin@redhat.com)
- new pre.cli styles within console (sgoodwin@redhat.com)
- 838353 link fix (sgoodwin@redhat.com)
- Bug 814025 Prevent external redirects on login, logout, and a few other
  places (ccoleman@redhat.com)

* Mon Jul 09 2012 Dan McPherson <dmcphers@redhat.com> 0.95.7-1
- Add better debugging to session_trace in development mode, remove some
  unnecessary trace statements (ccoleman@redhat.com)
- Balance news and learn sections of the homepage with bottom margin
  (ccoleman@redhat.com)
- At Legal's request, change the footer link for 'Terms of Service' to point to
  the preview services agreement. (ccoleman@redhat.com)

* Thu Jul 05 2012 Adam Miller <admiller@redhat.com> 0.95.6-1
- Ensure rails cache is cleared before tests and fix incorrect cache entries
  (ccoleman@redhat.com)
- Update cartridge type (ccoleman@redhat.com)
- React to cartridge metadata by removing need for :framework category.
  (ccoleman@redhat.com)
- all css changes... align center footer when in mobile portrait display. set
  app name and app url on same line when space allows, and set max-width with
  text-overflow:ellipsis to address bz 832900 (sgoodwin@redhat.com)
- Merge branch 'master' of github.com:openshift/li (sgoodwin@redhat.com)
- Unable to log into site in devenv, changing mock implementation resulted in
  form parameters being wrong. (ccoleman@redhat.com)
- 834714 css fix (sgoodwin@redhat.com)
- US2361 - Allow user to be automatically logged in after signup, and allow
  redirect after signup back to originating page.  Add lots and lots and lots
  of testing. (ccoleman@redhat.com)

* Mon Jul 02 2012 Adam Miller <admiller@redhat.com> 0.95.5-1
- added rubygem-wddx to requires/buildrequires for site rpm
  (admiller@redhat.com)

* Mon Jul 02 2012 Adam Miller <admiller@redhat.com> 0.95.4-1
- Updated omniture script to send stg data to correct report suites
  (spurtell@redhat.com)
- US2500 - Prototype aria billing in the site, includes massive chunks of new
  code.  Adds aria client wrapper, config for connecting to aria, new
  controllers, test cases, and should handle when the current system doesn't
  have access to aria gracefully. (ccoleman@redhat.com)
- Add requires for transitions, fix build break (ccoleman@redhat.com)
- Bug 834727 - Use Compass helpers to get full browser support on rotating O
  (ccoleman@redhat.com)
- update streamline ip (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.95.3-1
- new package built with tito

* Thu Jun 21 2012 Adam Miller <admiller@redhat.com> 0.95.2-1
- fix eap url (bdecoste@gmail.com)
- Bug 820760 - Background animated images don't work, copy hidden source image
  url (ccoleman@redhat.com)

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 0.95.1-1
- bump_minor_versions for sprint 14 (admiller@redhat.com)

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 0.94.16-1
- BZ833654: Removed extra flashes if the string is blank (fotios@redhat.com)
- Allow streamline to return login or emailAddress (as confirmation of email
  login) (ccoleman@redhat.com)
- Merge branch 'master' of git:/srv/git/li (sgoodwin@redhat.com)
- css edits - fix for 832900 (sgoodwin@redhat.com)
- Bug 830670 - Remove cartridge user guide link. (ccoleman@redhat.com)
- Bug 825094 - Prevent clickjacking through use of X-Frame-Options: SAMEORIGIN
  (ccoleman@redhat.com)

* Tue Jun 19 2012 Adam Miller <admiller@redhat.com> 0.94.15-1
- Update homepage with EAP6 info (ccoleman@redhat.com)
- BZ828116: Added logic for displaying credentials for applications created
  from templates (fotios@redhat.com)
- Update some of the cartridge text to be less verbose (ccoleman@redhat.com)

* Mon Jun 18 2012 Adam Miller <admiller@redhat.com> 0.94.14-1
- merge fix in pricing.scss (sgoodwin@redhat.com)
- fix layout issues for bug 832926 (sgoodwin@redhat.com)
- Minor wording of login placeholder (ccoleman@redhat.com)
- Update helpers to fix broken link on get_started page for JBoss tools
  (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Removed flexbox model styling form pricing page (spec still very unstable)
  (ffranz@redhat.com)
- Bug 819402 - Streamline sometimes returns 401 + specific service error, which
  is not an AccessDeniedException scenario. (ccoleman@redhat.com)
- minor spacing changes for lists and on the search input (sgoodwin@redhat.com)

* Fri Jun 15 2012 Adam Miller <admiller@redhat.com> 0.94.13-1
- Bug 832290 - Publish remote access page (ccoleman@redhat.com)
- Bug 827531 - Link to add cart page from getting started (ccoleman@redhat.com)

* Thu Jun 14 2012 Adam Miller <admiller@redhat.com> 0.94.12-1
- Add caching to drupal views and blocks for better performance.  Remove
  unnecessary sections from UI (ccoleman@redhat.com)
- Improved gears background images (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Pricing page styles and images (ffranz@redhat.com)
- Add unit tests for and gracefully handle when cartridges are added without
  metadata Speed up application and cartridge tests by reusing existing apps
  (ccoleman@redhat.com)
- updated URL of pricing page for custom tracking variable
  (spurtell@redhat.com)
- fix typos (sgoodwin@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- More pricing page styling, gears background images (ffranz@redhat.com)
- Show only a single error message when hit gear limit on creation.
  (ccoleman@redhat.com)
- Clean up cartridge layout at low resolutions (ccoleman@redhat.com)
- Minor pricing page style adjustments (ffranz@redhat.com)
- add test to make sure JBoss EAP comes befor JBoss AS (johnp@redhat.com)
- make sure JBoss EAP comes before JBoss AS (johnp@redhat.com)
- Added FAQ section content, styling (ffranz@redhat.com)
- New separated file for pricing styles (ffranz@redhat.com)
- remove space before parens in function call (johnp@redhat.com)
- functional tests for sshkey cache (johnp@redhat.com)
- make ssh urls and git show up only if the user has added their ssh key
  (johnp@redhat.com)
- add ssh_key caching (johnp@redhat.com)
- add ssh url to application overview (johnp@redhat.com)
- Merge branch 'master' of git:/srv/git/li (sgoodwin@redhat.com)
- mobile ui tuning (sgoodwin@redhat.com)
- Styling for the pricing page (ffranz@redhat.com)

* Wed Jun 13 2012 Adam Miller <admiller@redhat.com> 0.94.11-1
- add text to getting started application page for JBoss Dev Studio
  (johnp@redhat.com)
- Merge branch 'master' of git:/srv/git/li (sgoodwin@redhat.com)
- fix header spacing and such, change action-call on home (sgoodwin@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 0.94.10-1
- Modularize security helpers in application controller for better readability
  and consistency with other security solutions. Provide a session level cache
  for user domain info and listen for create/delete events.  Use the cache when
  viewing pages, but not on update pages. (ccoleman@redhat.com)
- Add :new tag to EAP (ccoleman@redhat.com)
- Gemfile.lock no longer has dependencies on a few extra modules
  (ccoleman@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 0.94.9-1
- explict height set on form fields and minor visual adjustment in console
  (sgoodwin@redhat.com)
- fix to force wrap long strings within table cells (sgoodwin@redhat.com)
- Merge branch 'master' of git:/srv/git/li into searchmod (sgoodwin@redhat.com)
- incorporate search field within header of site pages, reset headings to use
  line-height instead of margin-bottom, reset /stylesheets/_type.scss to
  bootstrap/_type.scss and merge customizations within so that we only use
  single _type file, minor tinkerings and condensing of styles
  (sgoodwin@redhat.com)
- Merge branch 'master' of git:/srv/git/li into searchmod (sgoodwin@redhat.com)
- Merge branch 'master' of git:/srv/git/li into searchmod (sgoodwin@redhat.com)
- modifications to search in header within drupal pages (sgoodwin@redhat.com)
- Initial incorporation of search within ui header (sgoodwin@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> 0.94.8-1
- Update of spec file (admiller@redhat.com)
- Display the current scale multiplier in the UI and add feature enablement
  pages that allow users to understand how scaling is exposed. Add a build
  feature enabler into the application overview page that lets users easily add
  and remove Jenkins support to their application. (ccoleman@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> - 0.94.7-1
- Display the current scale multiplier in the UI and add feature enablement
  pages that allow users to understand how scaling is exposed. Add a build
  feature enabler into the application overview page that lets users easily add
  and remove Jenkins support to their application. (ccoleman@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> 0.94.6-1
- remove requires aws-sdk, these apparently don't actually need it
  (admiller@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> 0.94.5-1
- need hard requires of rubygem-aws-sdk version for rhc-site spec file
  (admiller@redhat.com)

* Fri Jun 08 2012 Adam Miller <admiller@redhat.com> 0.94.3-1
- Remove black bar from simple layout (ccoleman@redhat.com)
- Updating jquery version to fix new bootstrap issue
  (fotioslindiakos@gmail.com)
- Fix JS error with reenabling the loading button (ccoleman@redhat.com)
- Update the help link for the getting_started page (ccoleman@redhat.com)
- Updated tracking.js with KissInsights integration, pricing page var, and
  Origin download tracking (spurtell@redhat.com)
- Made sure application_types index page works when no templates exist
  (fotioslindiakos@gmail.com)
- Add EAP metadata, clean up the creation pages a bit more, fix an empty box on
  app creation. (ccoleman@redhat.com)
- bz 827994 changes to next steps page, change experimental label to use just
  default label style, remove label hover, add spacing in btw p + heading
  (sgoodwin@redhat.com)
- Updated gem info for rails 3.0.13 (admiller@redhat.com)

* Mon Jun 04 2012 Adam Miller <admiller@redhat.com> 0.94.2-1
- Merge branch 'master' of git:/srv/git/li (sgoodwin@redhat.com)
- css updates for labels, breadcrumbs, help section in console, blogs
  (sgoodwin@redhat.com)
- Merge branch 'net_http_persistent' (ccoleman@redhat.com)
- Added detailed steps to the Getting Started page about installing cli on
  windows (ffranz@redhat.com)
- Reuse HTTP object more efficiently (ccoleman@redhat.com)
- Keep local copy of gear_groups until Application.reload (ccoleman@redhat.com)
- Merge branch 'master' into net_http_persistent (ccoleman@redhat.com)
- Update index (ccoleman@redhat.com)
- Update terminology to avoid "templates" being exposed to users.
  (ccoleman@redhat.com)
- Bug 826651 - Can't login to mock devenv with @ in login, use Base64 encoding
  instead of CGI double encoding (ccoleman@redhat.com)
- Pass all tests (ccoleman@redhat.com)
- Merge branch 'master' into net_http_persistent (ccoleman@redhat.com)
- Implement part of persistent local http connections (ccoleman@redhat.com)
- Add net-http-persistent to site. (ccoleman@redhat.com)
- Print a message when a user's cookie cannot be decoded (ccoleman@redhat.com)
- Bug 822018 - Remove JS validation on domain create/edit forms for simplicity
  (ccoleman@redhat.com)
- Bug 811391 - Users with '+' in them can't stay logged in under non-integrated
  environment (ccoleman@redhat.com)

* Fri Jun 01 2012 Adam Miller <admiller@redhat.com> 0.94.1-1
- bumping spec versions (admiller@redhat.com)
- Fixed minor typo (fotioslindiakos@gmail.com)

* Thu May 31 2012 Adam Miller <admiller@redhat.com> 0.93.12-1
- Removed experimental tag from DIY cart (fotioslindiakos@gmail.com)
- Added experimental label and adding spacing between multiple labels
  (fotioslindiakos@gmail.com)

* Thu May 31 2012 Adam Miller <admiller@redhat.com> 0.93.11-1
- 818653 (sgoodwin@redhat.com)
- Stylized template information in applications list
  (fotioslindiakos@gmail.com)
- BZ826972: Fixing application template link (fotioslindiakos@gmail.com)

* Wed May 30 2012 Adam Miller <admiller@redhat.com> 0.93.10-1
- Added application_templates to site (fotioslindiakos@gmail.com)
- Revert "Merge branch 'dev/fotios/descriptor'" (admiller@redhat.com)
- styling for application templates additions (sgoodwin@redhat.com)
- Moved templates to their own row in the view (fotioslindiakos@gmail.com)
- Added views for new application_templates (fotioslindiakos@gmail.com)
- Merge branch 'dev0530' (sgoodwin@redhat.com)
- fix for bz 820842 and enable outage status link display at view <768
  (sgoodwin@redhat.com)
- Fixes BZ 821103 (ffranz@redhat.com)
- mostly css changes - adjustments to breadcrumb, headings, collapsed nav
  order. haml change - add my account tab back into console default nav.
  (sgoodwin@redhat.com)

* Tue May 29 2012 Adam Miller <admiller@redhat.com> 0.93.9-1
- fine tuning position of ui at individual responsive breakpoints, correct
  utility nav drop menu and alert status message presentation and other ui
  tweaks (sgoodwin@redhat.com)

* Sun May 27 2012 Dan McPherson <dmcphers@redhat.com> 0.93.8-1
- add base package concept (dmcphers@redhat.com)

* Fri May 25 2012 Adam Miller <admiller@redhat.com> 0.93.7-1
- Bug 821103 - Send promo code to registration endpoint via streamline
  (ccoleman@redhat.com)
- Users were being logged in to the broker with the wrong rhlogin in non-
  integrated mode (ccoleman@redhat.com)
- Bug 811391 - Users with '+' in them can't stay logged in under non-integrated
  environment (ccoleman@redhat.com)
- Bug 822018 - Remove JS validation on domain create/edit forms for simplicity
  (ccoleman@redhat.com)
- Merge branch 'master' of git:/srv/git/li (sgoodwin@redhat.com)
- auto merge conflict fixes to console.scss and console/_ribbon.scss Merge
  branch 'mobileui' (sgoodwin@redhat.com)
- status alert header msg fix, minor spacing and font-type changes
  (sgoodwin@redhat.com)
- fix horizontal scroll at <767, and adjustment tuning (sgoodwin@redhat.com)
- css/markup to enable responsive nav for mobile views and lots of fine tuning
  of ui components in both site and console (sgoodwin@redhat.com)

* Thu May 24 2012 Adam Miller <admiller@redhat.com> 0.93.6-1
- Bug 824913 - Add helper code to filter certain parameter values from logged
  hashes (instead of using Rails helper code that wasn't working)
  (ccoleman@redhat.com)
- New installation instructions on Windows (ffranz@redhat.com)

* Wed May 23 2012 Adam Miller <admiller@redhat.com> 0.93.5-1
- Adding application template support (fotioslindiakos@gmail.com)

* Wed May 23 2012 Adam Miller <admiller@redhat.com> 0.93.4-1
- Blank flashes are duly ignored (ccoleman@redhat.com)
- Update cartridge link on getting started page to point to Platform Features
  page. (ccoleman@redhat.com)
- CSS cleanup of application header and application list, make headers share
  CSS and degrade gracefully, and make application lists flush with the left
  margin (ccoleman@redhat.com)
- Unit test for gear state output (ccoleman@redhat.com)

* Tue May 22 2012 Adam Miller <admiller@redhat.com> 0.93.3-1
- Add more information to the status app Update overview text with less
  hyperbolic descriptions (ccoleman@redhat.com)
- Bug 822936 - Remove old reference to express. (ccoleman@redhat.com)
- Cache streamline email address loading per user to speed up my account page
  (ccoleman@redhat.com)
- Provide a tiered application view that shows cartridges organized by what
  resources they share Expose Jenkins builds as an embedded component within a
  cartridge Implement a unified cartridge / application type model with caching
  (ccoleman@redhat.com)

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.93.2-1
- Unit test now passes with bug 812060 fixed (ccoleman@redhat.com)
- Bug 804937 - Update to use the correct exit code for the message
  (ccoleman@redhat.com)
- Remove puts (ccoleman@redhat.com)
- Gear state (ccoleman@redhat.com)
- Basic gear group code (ccoleman@redhat.com)
- re enable mixin inputGridSystem-generate (sgoodwin@redhat.com)
- Merge branch 'dev0510' (sgoodwin@redhat.com)
- another tweak for search-query class (sgoodwin@redhat.com)
- update to tracking.js (spurtell@redhat.com)
- Merge branch 'master' of git:/srv/git/li (spurtell@redhat.com)
- community search field fix for ipad/chrome width issue (sgoodwin@redhat.com)
- More fixes for input field width sizing (sgoodwin@redhat.com)
- Merge branch 'master' of git:/srv/git/li into dev0510 (sgoodwin@redhat.com)
- Add helper to generate technologies page for dev center (ccoleman@redhat.com)
- Make username drop menu position absolute at mobile sizes to enable topmost
  position on open, Fix search field to use modified mixin inputGridSystem-
  inputColumns and set have it's width set appropriate to grid. And a few other
  minor visual mods... (sgoodwin@redhat.com)
- Merge branch 'master' of git:/srv/git/li (spurtell@redhat.com)
- Updated tracking.js with Google Analytcs and AdWords code
  (spurtell@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.93.1-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (admiller@redhat.com)
- bumping spec versions (admiller@redhat.com)
- Bug 818030 - Remove opensource disclaimer page (ccoleman@redhat.com)
- Fix username dropdown-menu at responsive sizes, tweak wizard styles
  (sgoodwin@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.92.6-1
- alignment issue fix on docs page (sgoodwin@redhat.com)
- add error-client class to correct state handling on form submits
  (johnp@redhat.com)
- Make forum thread list much simpler (ccoleman@redhat.com)
- Make status ribbon be a bit cleaner in console (ccoleman@redhat.com)
- Update logo invoice (ccoleman@redhat.com)
- Bug 817447 - Feedback from david about getting started page
  (ccoleman@redhat.com)
- Bug 817892 - Grammar police are out in force (ccoleman@redhat.com)
- CSS tweaks to bring content into better visual appearance, restore some minor
  problems (ccoleman@redhat.com)
- Cancel button on delete always returns user to application details page (more
  consistent), fix logging bug, and terms page should use simpler title style.
  (ccoleman@redhat.com)
- Bug 820151 - Show the account information for jenkins on app creation,
  refactor message passing on cart creation, remove layout/_flashes and replace
  with simpler helper, ensure pages are flashing in the right spot, add a new
  :info_pre flash type that renders with preformatted output (don't like the
  name, but eh) (ccoleman@redhat.com)
- Bug 819441 - Some account related paths should not be redirected back to
  (ccoleman@redhat.com)
- Bug 817907 - Really REALLY don't set cookies from status app.  Also fix
  issues with starting status app in failure mode. (ccoleman@redhat.com)
- Basic compact left navigation (ccoleman@redhat.com)
- Simplify how the dropdown link is generated, use a view helper
  (ccoleman@redhat.com)

* Tue May 08 2012 Adam Miller <admiller@redhat.com> 0.92.5-1
- Merge branch 'devcomm' (sgoodwin@redhat.com)
-  minor updates to the visual presentation of the forums threat list and blog
  details views (sgoodwin@redhat.com)

* Tue May 08 2012 Adam Miller <admiller@redhat.com> 0.92.4-1
- Make the delete button more subtle (ccoleman@redhat.com)
- Merge branch 'cleanupscss' (sgoodwin@redhat.com)
- button disabled/active changes (sgoodwin@redhat.com)
- Reenable Jenkins from the UI (ccoleman@redhat.com)
- Add an informational page on logout that informs the user that they have been
  logged out and why.  Currently just takes the user back to the account page.
  (ccoleman@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.92.3-1
- add navbar tests back and add unique classes to links (johnp@redhat.com)
- Fix bug 818391 - special code branch should have been removed when we fixed
  bug 789786 (ccoleman@redhat.com)
- shadowman icon for username association (sgoodwin@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.92.2-1
- Fix failing test from renaming red hat network identity (ccoleman@redhat.com)
- Update styles on terms controller, remove captcha there.
  (ccoleman@redhat.com)
- Change from 'red hat network' to 'red hat' terminology. (ccoleman@redhat.com)
- Remove extra role establish call on login. (ccoleman@redhat.com)
- Merge branch 'dev0430' (sgoodwin@redhat.com)
- separate console button styles out from site into their own partial scss
  (sgoodwin@redhat.com)
- Merge events recent changes and user profile into code. (ccoleman@redhat.com)
- pull duplicate style, add mixin box-shadow (sgoodwin@redhat.com)
- more scss cleanup. button work, username dropdown and ribbon polish
  (sgoodwin@redhat.com)
- Merge branch 'master' of git:/srv/git/li into dev0430 (sgoodwin@redhat.com)
- scss css cleanup (sgoodwin@redhat.com)
- Failure during cartridge creation, tests not as good as we thought.
  (ccoleman@redhat.com)
- Simplify how we handle cart type models Prevent bad custom_ids from being
  passed Fix bug with CartridgeType retrieval (ccoleman@redhat.com)
- Prefix mappings were screwed up and breaking unit tests.  Now use
  RestApi::Base.prefix everywhere (ccoleman@redhat.com)
- new _buttons and _dropdowns partials for console and color corrected logo
  (sgoodwin@redhat.com)
- Merge branch 'master' of git:/srv/git/li into dev0430 (sgoodwin@redhat.com)
- color scale added for console and change styleguide/console markup to bring
  into alignment with latest (sgoodwin@redhat.com)
- Remove duplicate slash from request URLs (ccoleman@redhat.com)
- Instrument ActiveResource to logs (ccoleman@redhat.com)
- Loading icon needs to be reinstated Update loading script
  (ccoleman@redhat.com)
- Add better association logic Allow objects to be passed to RestApi::Base
  initialize method to handle belongs_to Add more assignment unit tests Ensure
  change notifications are cleared by the save() command Remove unnecessary
  check in domain save Test changes? more thoroughly (ccoleman@redhat.com)
- Fix formatting of error messages when form is using input-prepends
  (ccoleman@redhat.com)
- Update community side nav-column font color/size and fix ipad search field
  issue. Adjust console colors, center nav, breadcrumb and other minor visual
  changes. (sgoodwin@redhat.com)
- Package rename python(3.2 -> 2.6), ruby(1.1 -> 1.8) (kraman@gmail.com)
- Merge branch 'dev/clayton/identity' (ccoleman@redhat.com)
- Add passing status_app_test for null issues (ccoleman@redhat.com)
- Use simple user to extract identity (ccoleman@redhat.com)
- Fix styleguide (ccoleman@redhat.com)
- Ensure exceptions are loaded optimistically for streamline
  (ccoleman@redhat.com)
- Ensure type is correctly loaded from session (ccoleman@redhat.com)
- Refactor streamline into multiple objects that cleanly define usage Make
  inheritance act normally Remove autoload of lib sub-directories (so that
  Rails autoloading picks up module namespaces) (ccoleman@redhat.com)
- Add a type attribute on streamline user (ccoleman@redhat.com)
- Move attributes to Streamline::Base for resharing (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/identity (ccoleman@redhat.com)
- Ensure status app cannot set session cookies, add tests.
  (ccoleman@redhat.com)
- Get tests to passing with better abstraction of name change logic and role
  setting in streamline_test.rb (ccoleman@redhat.com)
- Unit tests for status (ccoleman@redhat.com)
- Ensure status app cannot set session cookies (ccoleman@redhat.com)
- Status app should not set cookies (ccoleman@redhat.com)
- Fix bugs with recording time of streamline calls (ccoleman@redhat.com)
- Add streamline time tracing (ccoleman@redhat.com)
- Make streamline attribute writers protected to prevent general access Prevent
  rhlogin from being updated except by Streamline code Allow captcha_secret to
  be provided on login URL for simpler login sequence in kiosks Change
  establish_email_address to load_email_address Fine tune identity display on
  account page to show link to RHN account page When access denied exception is
  thrown write backtrace (ccoleman@redhat.com)
- Fix unit test failure on nil test (ccoleman@redhat.com)
- Centralize roles load logic (ccoleman@redhat.com)
- Update identity to have better display name (ccoleman@redhat.com)
- Add identity display to ui (ccoleman@redhat.com)
- Bug 817627 - Prevent infinite redirect of users who have invalid rh_sso
  tokens (ccoleman@redhat.com)
- Add tests to handle infinite redirect bug (ccoleman@redhat.com)
- Move accessors (squash) (ccoleman@redhat.com)
- Refactor some of the establish scenarios to be cleaner (ccoleman@redhat.com)
- Adjust margin settings for console at >767 widths, remove inadvertant btn
  box-shadow default, center console nav per design, and a few other minor
  tweaks to spacing in the console (sgoodwin@redhat.com)
- Finish breadcrumb (ccoleman@redhat.com)
- Alter head ribbon to use a simpler style of wrapping (ccoleman@redhat.com)
- Start whittling console.scss down, fix ribbon to flush correctly
  (ccoleman@redhat.com)
- css tweeks (sgoodwin@redhat.com)
- Add FireSASS support (ccoleman@redhat.com)
- More aggressive gitignore (ccoleman@redhat.com)
- Write expanded CSS in dev mode (ccoleman@redhat.com)
- Rename to make a generic tracking file and tracking JS file Provide query
  parameters for promo_code on emails Remove warnings on test runs Add test
  cases for promo code redirect Make it so that a refresh is not required to
  enter a promo code. Fix failures in test env on mailer. (ccoleman@redhat.com)
- Community nav column is creating a white bar on iphone (ccoleman@redhat.com)
- Removed mirror.openshift.com tests until it goes public (ffranz@redhat.com)
- Fixes BZ 816797 (ffranz@redhat.com)
- Remove 'by Red Hat' from site (ccoleman@redhat.com)
- Updated requirements from legal regarding removal of opensource disclaimer
  page and changes to language on download page. (ccoleman@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.92.1-1
- new loader image for console and css (sgoodwin@redhat.com)
- bumping spec versions (admiller@redhat.com)
- Update logo-24-inside to not have improper color saturation on firefox
  (ccoleman@redhat.com)
- Origin SRPMs on download page (ccoleman@redhat.com)

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 0.91.11-1
- Merge branch 'dev0425' (sgoodwin@redhat.com)
- event section styles added (sgoodwin@redhat.com)

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 0.91.10-1
- Create a stub logo invoice (ccoleman@redhat.com)
- Bug 815173 - Set header in drupal to force IE edge mode in devenv.   Ensure
  that status messages won't be shown for N-1 compat with site   Update
  copyright colors to be black background   Update copyright date
  (ccoleman@redhat.com)
- Fixes #816081 (ffranz@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 0.91.9-1
- Links to live cd Navbar tweaks to fit in small spaces Remove "new" tag on
  node.js (ccoleman@redhat.com)
- Better wrapping of header on phone (ccoleman@redhat.com)
- Added warning color and some tweaks to content width (ccoleman@redhat.com)
- More button tweaks, some table fixes.  Will need to further pursue items next
  sprint. (ccoleman@redhat.com)
- Heavy refactoring of nav header code (ccoleman@redhat.com)
- Remove navbar-inner, not used (ccoleman@redhat.com)
- Move navbar code into _navbar (ccoleman@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 0.91.8-1
- Improved responsiveness for dropdown navbar (ffranz@redhat.com)
- Improved responsiveness for dropdown navbar (ffranz@redhat.com)
- Fixes #815261 (ffranz@redhat.com)
- Merge branch 'dev0424' (sgoodwin@redhat.com)
- Tighten up opensource download page (sgoodwin@redhat.com)
- Fixes #815698 by handling invalid constant names; rest api auto detects proxy
  (ffranz@redhat.com)
- Bug 814573 - Fix up lots of links to www.redhat.com/openshift/community
  (ccoleman@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 0.91.7-1
- sync error handling client side and server side (johnp@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.91.6-1
- Disable Jenkins because upstream bugs could not be fixed.
  (ccoleman@redhat.com)
- Merge branch 'dev0423' (sgoodwin@redhat.com)
- revised button styles, search field focus (sgoodwin@redhat.com)
- Mark's suggestions (ccoleman@redhat.com)
- Better opensource links and descriptions (ccoleman@redhat.com)
- Update to LiveCd with kraman's agreement (ccoleman@redhat.com)
- Reorder items in user_profile_box to work better with Steve's styling
  (ccoleman@redhat.com)
- Touch up blog theme prior to ship (ccoleman@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.91.5-1
- Change #console-head to .console-head for selectivity fix
  (ccoleman@redhat.com)
- Fix breadcrumbs on lots of console pages, add blue add cart button to app
  details page (ccoleman@redhat.com)
- max-widths off by one Replace console-panel with section-console (may change
  selectivity) (ccoleman@redhat.com)
- Fix warning on applications index page (ccoleman@redhat.com)
- Split out urls for git/opensource into their own file to reduce
  application_helper size Remove unused _pageheader file Switch order of page
  title - current page title comes first, then the generic 'Openshift by
  redhat' message Improve text on index.html.haml page Changes to opensource
  download page to reflect new structure of page (ccoleman@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 0.91.4-1
- Added styles for the ToC of wiki pages (ffranz@redhat.com)
- minor spacing changes in community forum (sgoodwin@redhat.com)
- Tests mildly out of sync with controllers in bug 814835 (ccoleman@redhat.com)
- Merge branch 'dev0420' (sgoodwin@redhat.com)
- community pages - ui css changes (sgoodwin@redhat.com)
- Reads better this way (ccoleman@redhat.com)
- Bug 814835 - Password reset should not expose whether the user has an account
  (ccoleman@redhat.com)
- isolate column-content div only (sgoodwin@redhat.com)
- Merge branch 'dev0420' (sgoodwin@redhat.com)
- community comments changes (sgoodwin@redhat.com)
- Bug 808657 - Users who signup should be taken to the console after their
  first login (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Bug 814575 - Developers link is missing (ccoleman@redhat.com)
- minor edit to go along with forum changes (sgoodwin@redhat.com)
- Reformat forum thread and comments (sgoodwin@redhat.com)
- Added styles for the ToC of wiki pages (ffranz@redhat.com)
- Fix cartridge tests to use new assigns names (ccoleman@redhat.com)
- Merge branch 'dev/clayton/console-branding' (ccoleman@redhat.com)
- Added styles for the ToC of wiki pages (ffranz@redhat.com)
- Lots of cleanup of getting started and next steps (ccoleman@redhat.com)
- community forum layout changes and remove input box-shadow from console
  (sgoodwin@redhat.com)
- comment out visual blocks which we don't have any data for yet
  (johnp@redhat.com)
- [security] do not call html_safe on error messages (johnp@redhat.com)
- Prevent pictures in left nav from getting too big (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/console-branding (ccoleman@redhat.com)
- Give Jenkins some info and a link to a help page (ccoleman@redhat.com)
- minor edits (sgoodwin@redhat.com)
- Help documents update (ccoleman@redhat.com)
- Tweaks to console help (ccoleman@redhat.com)
- Fixes duplicate arrows for external links on wiki (ffranz@redhat.com)
- more merge fixes (johnp@redhat.com)
- fix merge issues (johnp@redhat.com)
- update my applications page to dark console ui (johnp@redhat.com)
- Remove section help (ccoleman@redhat.com)
- Revert changes to console help, update footer sections to be cleaner
  (ccoleman@redhat.com)
- Unbreak layout for J5 (ccoleman@redhat.com)
- A few less styles, some slightly cleaner grid behavior for help
  (ccoleman@redhat.com)
- Other dark_layout page, a few color tweaks for readability on get started
  page.  Fix remaining styleguides (ccoleman@redhat.com)
- Alternate dark_layout implementation, change #console-panel to .section-
  console and .row-console to be consistent with site (ccoleman@redhat.com)
- Update links on homepage to new features this sprint (ccoleman@redhat.com)
- update cartridge_type selection and addition styles (johnp@redhat.com)
- style dark layout closer to mockups (johnp@redhat.com)
- style application details page (johnp@redhat.com)
- add dark_layout to console and have the applications::show controller use it
  (johnp@redhat.com)
- update breadcrumb helper to add delimiters and an active class
  (johnp@redhat.com)
- Restore color overrides on form errors that were lost during _custom.css
  normalization (ccoleman@redhat.com)
- add breadcrumbs helper and content_for block to the layout (johnp@redhat.com)
- fix styling on create app page (johnp@redhat.com)
- Abstract out messaging and handle navbar bottom margin a bit cleaner
  (ccoleman@redhat.com)
- fix link color and dropdown arrow position (johnp@redhat.com)
- fix up dropdown style a bit more (johnp@redhat.com)
- remove import to nonexitant file (johnp@redhat.com)
- minor position edits and class change on get started (sgoodwin@redhat.com)
- Remove console-transition (ccoleman@redhat.com)
- Some basic stuff to verify that the styles were properly merged
  (ccoleman@redhat.com)
- Merge branch 'dev/clayton/console-branding' of git:/srv/git/li into
  dev/clayton/console-branding (ccoleman@redhat.com)
- Switch to using common.scss for console, mostly refactored
  (ccoleman@redhat.com)
- Move stuff moved out of _custom.scss (ccoleman@redhat.com)
- make header more like mockups (johnp@redhat.com)
- Moving stuff out of custom.scss (ccoleman@redhat.com)
- Split out buttons (ccoleman@redhat.com)
- add dropdown user menu to user's login in header (johnp@redhat.com)
- upgrade to jquery-1.7.2 and add bootstrap-dropdown.js dropdown menu widget
  (johnp@redhat.com)

* Wed Apr 18 2012 Adam Miller <admiller@redhat.com> 0.91.3-1
- Status app now causing warning on redefinition in test - hack around it
  (ccoleman@redhat.com)
- Bug 813616 - Instruct users about the optional RHEL 6.2 channel for getting
  'rubygems' (ccoleman@redhat.com)
- Bug 813613 (ccoleman@redhat.com)
- Abstract out messaging and handle navbar bottom margin a bit cleaner
  (ccoleman@redhat.com)
- Fix domain controller failures, bonehead move. (ccoleman@redhat.com)
- new console prototype pages for reference (sgoodwin@redhat.com)
- Fixed image overflow at small sizes in product overview page.
  (edirsh@redhat.com)
- Update getting started page to be a "bit" prettier (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/community_urls (ccoleman@redhat.com)
- Enable Jenkins as an app (ccoleman@redhat.com)
- Fix fake_before_filter_test, add pending/error access request pages
  (ccoleman@redhat.com)
- Merge remote-tracking branch 'origin/master' into dev/fotios/login
  (ccoleman@redhat.com)
- Add GitHub link to footer (ccoleman@redhat.com)
- Link the redhat image to https://www.redhat.com/ (ccoleman@redhat.com)
- Enable the opensource and download controllers for production
  (ccoleman@redhat.com)
- First stab at new navigation / footer layout (ccoleman@redhat.com)
- Remove old layout files (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/community_urls (ccoleman@redhat.com)
- Fix two test changes (ccoleman@redhat.com)
- Merged some test improvements made upstream (ccoleman@redhat.com)
- Merge branch 'master' into dev/fotios/login (ccoleman@redhat.com)
- Get terms controller test passing (ccoleman@redhat.com)
- Center the signup terms to balance the page (ccoleman@redhat.com)
- Move AccessDeniedException to an appropriate place, ensure it is autoloaded,
  fix syntactical vagueness in unit test (ccoleman@redhat.com)
- Minor reorganization (ccoleman@redhat.com)
- Switch to a much cleaner recaptcha and give the promo code an extra few
  pixels. (ccoleman@redhat.com)
- Remove sso cookie reset from login page (ccoleman@redhat.com)
- Make promo code suggestion simpler (ccoleman@redhat.com)
- Simple pages are wasting too much vertical space on the header
  (ccoleman@redhat.com)
- Allow the community theme to return to the current location after logout
  (ccoleman@redhat.com)
- Allow streamline to be dynamically reloaded when it changes Fix logout flow
  to use standard streamline config (ccoleman@redhat.com)
- Updated test_helper.rb to match latest changes from master Merged
  application_controller (ccoleman@redhat.com)
- Automatic commit of package [rhc-site] release [0.90.6-1].
  (mmcgrath@redhat.com)
- Simplify some styles on the opensource page, correct some phone/tablet layout
  issues. (ccoleman@redhat.com)
- Attached images list removed from Community Wiki using CSS display none
  (ffranz@redhat.com)
- restrict opensource download routes to dev instance (johnp@redhat.com)
- add all cart links to page (johnp@redhat.com)
- Add timing and parent branch removal Better comments in the change section
  Branch pruning and empty merge filtering Add password controller to
  exclusion, begin tidying opensource.sh up for final status. Indicate how many
  files will be preserved (ccoleman@redhat.com)
- Create draft file for creating open source engine on console
  (ccoleman@redhat.com)
- Tweak headers down except on home page, change header to point to the
  developers link. (ccoleman@redhat.com)
- Update forum_list view with menu fix Make relative URLs work from menus Minor
  CSS tweaks to community. (ccoleman@redhat.com)
- Merged login changes (fotios@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.2-1
- release bump for tag uniqueness (mmcgrath@redhat.com)
- Merge branch '0412dev' (sgoodwin@redhat.com)
- include fallback background color for ie since it doesn't support css3 linear
  gradients (sgoodwin@redhat.com)
- Update preview agreement to remove flex (ccoleman@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.16-1
- Unit tests for domains controller   Remove old :namespace error output in
  form   Make errors on domain correct for case when an error exists
  (ccoleman@redhat.com)
- Bug 811847 - Bad refactor, domain :edit not showing up (ccoleman@redhat.com)
- Fixes 807565 (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 807565 (ffranz@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.90.15-1
- fix for ie9 background-image bug and newsletter link lighten
  (sgoodwin@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.90.14-1
- Bug 804849; Improve styling of outage notification to match new branding
  (edirsh@redhat.com)
- Better integrate illustrations in overview page (edirsh@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.90.13-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Test commit (mmcgrath@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.90.12-1
- Remove debugging logic - it hath served its purpose (ccoleman@redhat.com)
- Merge branch 'dev/clayton/partners' (ccoleman@redhat.com)
- Reenable domain test (ccoleman@redhat.com)
- Remove partners from UI.  Footer in community as well (ccoleman@redhat.com)
- Bug 802634 - Improve the display of the search button on the Help page to
  make it clear it can be clicked, use styles from community.
  (ccoleman@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.11-1
- Temporarily disable test_domain_exists_error in domain_test.rb to allow AMI
  to build clean (ccoleman@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.10-1
- test commit (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.9-1
- Change requires for all test/units so that 'ruby test/unit/xxx.rb' runs the
  test (ccoleman@redhat.com)
- Bug 804018 - display a proper 404 when resources are not found   Until
  multiple domain support lands we were using Domain.first - this returns nil
  when an item exists.  Most .find methods that load a specific resource throw
  an exception.  We should be doing the same until multidomain lands (and after
  multidomain lands we should be looking up domains via id).  For now, use
  Domain.find :one, which was created to throw if there is no domain.  Updated
  unit tests.  Added rescue_from to ApplicationController, and added a note
  about Rails 3.1 (which will allow render :status => 404 instead of a more
  complicated output).  Controller should handle exceptions before redirecting
  (ccoleman@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.8-1
- Revert "Merged login changes" (fotios@redhat.com)
- fix vars in opensource download view (johnp@redhat.com)
- css fix added for 802640, ie bug and rearrangement of font family order
  (sgoodwin@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 811146 (ffranz@redhat.com)
- refactor gear_size_profile and node profile to gear_profile
  (johnp@redhat.com)
- fix github urls to agreed upon path for OpenSource repos (johnp@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.7-1
- Merged login changes (fotios@redhat.com)

* Mon Apr 09 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.6-1
- Simplify some styles on the opensource page, correct some phone/tablet layout
  issues. (ccoleman@redhat.com)
- Attached images list removed from Community Wiki using CSS display none
  (ffranz@redhat.com)
- restrict opensource download routes to dev instance (johnp@redhat.com)
- add all cart links to page (johnp@redhat.com)
- Add timing and parent branch removal Better comments in the change section
  Branch pruning and empty merge filtering Add password controller to
  exclusion, begin tidying opensource.sh up for final status. Indicate how many
  files will be preserved (ccoleman@redhat.com)
- Create draft file for creating open source engine on console
  (ccoleman@redhat.com)
- move generic css to site so everyone can use it (johnp@redhat.com)
- restyle opensource download page and add perliminary links (johnp@redhat.com)
- Fix infinite recursion in find_or_create_resource_for by inlining method
  React to changes from domain :name to domain :id   Remove legacy code
  referencing old :namespace attributes   Replace all references to domain
  :namespace with domain :name   Make custom_id in RestApi::Base override
  :to_param instead of :id     Clean up unit tests to reflect this change - .id
  and .name will now both show updates   Create new id alias methods to provide
  legacy support for the getter key.destroy works on the first key - update the
  test to check that (ccoleman@redhat.com)
- ActiveResource association support was not working, and when attributes with
  dashes are returned from REST API they throw a NameError.  Fix by sanitizing
  resource class names for ActiveResource autodeserialization before invoked
  (use a monkey patch on ActiveResource::Base) (ccoleman@redhat.com)
- better layout for opensource download page (johnp@redhat.com)
- tweak layout for download page (johnp@redhat.com)
- example of using the info-ribbon class (johnp@redhat.com)
- add a info-ribbon class to site.scss (johnp@redhat.com)

* Wed Apr 04 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.5-1
- modified file download to use mirror.openshift.com (fotios@redhat.com)
- make sure download link is a child of the containing element
  (johnp@redhat.com)
- Added download link to opensource page (fotios@redhat.com)

* Wed Apr 04 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.4-1
- Revert deletion of embedded until the deserialization problem can be fixed
  (ccoleman@redhat.com)
- add basic content and layout to opensource download page (johnp@redhat.com)
- add routes, controller and view for opensource download page
  (johnp@redhat.com)
- US2118: Fedora remix download support (fotios@redhat.com)

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.3-1
- Logo was missing from the simple header layouts (ccoleman@redhat.com)

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.2-1
- Add mts-bottom-transparent image for small forms page (edirsh@redhat.com)
- Remove the embedded model object as it is no longer used
  (ccoleman@redhat.com)
- Remove new_forms filter as all output should use new forms
  (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 808679 (ffranz@redhat.com)
- [ui] only show gear size if there is more than one option (johnp@redhat.com)

* Sat Mar 31 2012 Dan McPherson <dmcphers@redhat.com> 0.90.1-1
- bump spec numbers (dmcphers@redhat.com)
- Updates all links to docs for the new version that doesnt have Express on the
  URLs (ffranz@redhat.com)
- Fixes 807985 (ffranz@redhat.com)

* Thu Mar 29 2012 Dan McPherson <dmcphers@redhat.com> 0.89.10-1
- check to see if domain is being updated (johnp@redhat.com)
- mitigate race condition due to multiple domain support on the backend
  (johnp@redhat.com)
- Fixes 807985 (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 806763 and 802699 (ffranz@redhat.com)
- more fixes to gear size UI (johnp@redhat.com)
- add the gear size option to the create app view (johnp@redhat.com)
- Fixes 798128 (ffranz@redhat.com)

* Wed Mar 28 2012 Dan McPherson <dmcphers@redhat.com> 0.89.9-1
- 

* Wed Mar 28 2012 Dan McPherson <dmcphers@redhat.com> 0.89.8-1
- correct links and remove duplicates in opensource dislaimer page
  (johnp@redhat.com)
- Fixes 807063 (ffranz@redhat.com)
- Added logged in user information to console header (ffranz@redhat.com)
- when embedding cart put server output in an escaped pre tag
  (johnp@redhat.com)

* Tue Mar 27 2012 Dan McPherson <dmcphers@redhat.com> 0.89.7-1
- Fixes help links tests (ffranz@redhat.com)
- blacklist haproxy from the cartridge view for now (johnp@redhat.com)
- set error classes on username and password field if base error comes in
  (johnp@redhat.com)
- [sauce] fix error class assignment when creating app (johnp@redhat.com)
- Unit tests for help links so when they break we know (ccoleman@redhat.com)
- Fixed hard coded /app links in form (fotios@redhat.com)
- Fixed odd quotation in terms_controller (fotios@redhat.com)
- Fix for BZ806939: Login form password length validation (fotios@redhat.com)
- Delete .gitignore from public/javascripts (ccoleman@redhat.com)
- Clean up and refine overview and getting started (ccoleman@redhat.com)

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.6-1
- 

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.5-1
- Add treetop for good measure (ccoleman@redhat.com)
- Update site.spec to take a dependency at build and runtime on rubygem-mail
  (not being pulled in by dependency tree of existing rails packages in build
  env, so build fails) (ccoleman@redhat.com)

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.4-1
- 

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.3-1
- 

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.2-1
- remove missed "preview" tag from Management Console header (johnp@redhat.com)
- Whitelist allowable options to getting_started_external_controller
  (ccoleman@redhat.com)
- Clean up markup on appcelerator page (ccoleman@redhat.com)
- Update getting started page to be more attractive, include link to console.
  (ccoleman@redhat.com)
- Fixed merge problem related to app/models/express_cartlist.rb
  (ffranz@redhat.com)
- Removed deprecated node_js_enabled copnfiguration (ffranz@redhat.com)
- Properly clear application list at beginning of each unit test
  (ccoleman@redhat.com)
- remove all of the .to_delete files (johnp@redhat.com)
- fix OS disclaimer page merge issue (johnp@redhat.com)
- remove express models and tests (johnp@redhat.com)
- Removing legacy express code (fotios@redhat.com)
- Removed/changed references to express in current console (fotios@redhat.com)
- OS disclaimer - fix nodejs license (johnp@redhat.com)
- Clean applications at beginning of application controller test cases
  (ccoleman@redhat.com)
- Revert with_domain behavior to previous, add additional methods for tests
  that do or don't need a domain object.  Ensure cleanup in rest_api_tests is
  consistent. (ccoleman@redhat.com)
- Bug 806763 - Change order of rendering of form errors to be before hints
  (ccoleman@redhat.com)
- Bug 806785 - Reset SSO and session when password reset link received Treat
  empty rh_sso cookie as nil rh_sso cookie Remove Rails. prefix from controller
  logging (ccoleman@redhat.com)
- Remove development log from site build (ccoleman@redhat.com)
- Off by one media query errors cause footer columns to be wrong on ipad
  (ccoleman@redhat.com)
- Reorder application types to put node.js at the top (ccoleman@redhat.com)
- No lift-counter needed on the home page (ccoleman@redhat.com)
- Fix Overpass font to use correct Bold style, add OverpassNormal for old
  behavior Revert brand logo to use text, temporary fixes for narrow screens
  Update layout to use counter standard 'lift-counter' Add page titles to most
  pages, fixup markup to be consistent Remove .ribbon-content everywhere.
  (ccoleman@redhat.com)
- Bug 806145 - Removed lurking text. (ccoleman@redhat.com)
- Remove old console message (ccoleman@redhat.com)
- Tone down buzz section at small resolutions (ccoleman@redhat.com)
- Checkin default avatar (ccoleman@redhat.com)
- Add last vestiges of JS generation (ccoleman@redhat.com)
- Bug 806198 - Bow to public pressure, show distinct auth links based on state
  (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Bug 806026 - Revert iframe fix now that getting_started embedded videos are
  gone (ccoleman@redhat.com)
- Bug 805685 - Comment out link temporarily (ccoleman@redhat.com)
- User is not consistently being taken to console after login, because
  http_referrer isn't changed on redirects.  Pass destination as a redirectUrl
  parameter, stop using session variable. (ccoleman@redhat.com)
- Generate CSS and JS during build of site rpm, using bundle exec and
  barista/compass (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Support generic URL redirection based on the Rack SCRIPT_NAME
  (ccoleman@redhat.com)
- Getting started headlines (ffranz@redhat.com)
- Removed the last references to Flex from site codebase (ffranz@redhat.com)
- Fixed product controller functional tests (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Merge branch 'compass', removed conflicting JS file (ccoleman@redhat.com)
- merged with master (lnader@redhat.com)
- Add default barista config to autogenerate in development mode, and make
  production mode route directly Delete old JS files Delete previously
  generated JS files Fixup all stylesheet and javascript urls to be relative
  (ccoleman@redhat.com)
- Trying to fix broken tests (unable to reproduce), using setup_integrated
  instead of with_domain (ffranz@redhat.com)
- merge with master (lnader@redhat.com)
- Move overpass to app/stylesheets Remove generated CSS from public/stylesheets
  Remove deprecated projekktor_maccaco file (ccoleman@redhat.com)
- Broker and site in devenv should use RackBaseURI and be relative to content
  Remove broker/site app_scope (ccoleman@redhat.com)
- OS disclaimer - fix up licenses and links; remove redundant listings
  (johnp@redhat.com)
- Compass automatically generates stylesheets from app/stylesheets to
  tmp/stylesheets in dev mode, and Rack serves content from both of them in
  development and production. (ccoleman@redhat.com)
- prun some of the -devel packages and subpackages (johnp@redhat.com)
- Revert gemfile.lock back to earlier version (accidental commit)
  (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Removed references to Flex on site codebase, some tests may break
  (ffranz@redhat.com)
- Bad require left around (ccoleman@redhat.com)
- Compass initial code (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix test cases in site/test/functional/keys_controller_test.rb
  (rpenta@redhat.com)
- -1 is not the same as .1, fix bad site gemfile (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix key create/destroy tests in site/test/integration/rest_api_test.rb
  (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Add dependency on compass to Gem (ccoleman@redhat.com)
- Site needs an RPM dependency on rubygem-compass for CSS generation
  (ccoleman@redhat.com)
- Fixes 803654 (ffranz@redhat.com)
- Removed references to Flex on site codebase (ffranz@redhat.com)
- add initial list of open source packages to disclaimer page
  (johnp@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Removed references to Flex on site codebase (ffranz@redhat.com)
- US1876 (lnader@redhat.com)
- Update to haml 3.1, must use new AMI (ccoleman@redhat.com)
- add initial opensource disclaimer page, links and route (johnp@redhat.com)
- Removed Flex from some pages (ffranz@redhat.com)
- Redirect /user/new to /account/new, replace flex login sequence with generic
  sequence (ccoleman@redhat.com)
- Fix failing unit tests now that flex pages have been removed.
  (ccoleman@redhat.com)
- Improved spacing on getting started page (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Added Node.js on several marketing pages (ffranz@redhat.com)
- Use with_domain on Cart type controller vs setup_integrated (better cleanup)
  (ccoleman@redhat.com)
- Remove extra spaces which cause warnings (ccoleman@redhat.com)
- merge (mmcgrath@redhat.com)
- Update stickshift gemfiles to new rack versions, remove multimap which is no
  longer required by rack (versions before .7 had a dependency, it has since
  been inlined) (ccoleman@redhat.com)
- Merge branch 'rack' (ccoleman@redhat.com)
- Added redirect for legacy routes (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Removed Flex from top header nav links (ffranz@redhat.com)
- Fixes for BZ804845 and BZ803679 (fotios@redhat.com)
- Update rack dependencies (ccoleman@redhat.com)
- Update rack to 1.3 (ccoleman@redhat.com)
- Remove overly aggressive site rack dependency (should be open)
  (ccoleman@redhat.com)
- Merge branch 'dev/clayton/login' (ccoleman@redhat.com)
- Remove excess puts (ccoleman@redhat.com)
- check to see if conflicts and requires are available (johnp@redhat.com)
- Update login parameter in unit tests (ccoleman@redhat.com)
- Don't generate urls to the confirmation pages for flex/express - go only to
  confirm (ccoleman@redhat.com)
- Merge remote-tracking branch 'origin/master' into dev/clayton/login
  (ccoleman@redhat.com)
- Fix login tests to use new param (ccoleman@redhat.com)
- Testing flex confirmation redirects, more tests of email confirmation
  (ccoleman@redhat.com)
- Adding a default cfs_quota (mmcgrath@redhat.com)
- Redirect old /app/user/new/flex|express paths, fix unit tests
  (ccoleman@redhat.com)
- renamed haproxy (mmcgrath@redhat.com)
- Fix broken keys controller tests (ccoleman@redhat.com)
- fix for help-inline msg on _form.html.haml (sgoodwin@redhat.com)
- fix 803995 (sgoodwin@redhat.com)
- error msg display fix 803995 (sgoodwin@redhat.com)
- Bug 798128 (sgoodwin@redhat.com)
- Fix warning (ccoleman@redhat.com)
- Add more debugger logging to streamline for auth failures, fix problem with
  parameter names in login controller. (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/login (ccoleman@redhat.com)
- Add new methods to streamline_mock (ccoleman@redhat.com)
- Combine confirmation and success messages into a single form, remove old
  signin form, and fix redirection of new user to prefill email address.
  (ccoleman@redhat.com)
- Remove dead password code and views, everything moved to app/views/password
  and app/controllers/password_controller.rb (ccoleman@redhat.com)
- Redirect old password reset links to new password reset links
  (ccoleman@redhat.com)
- Autofocus on signin flow (ccoleman@redhat.com)
- Refresh login flow with updated code to streamline, clean up error text.
  (ccoleman@redhat.com)
- Add link to return to main page after reset (ccoleman@redhat.com)
- Cleanup email confirmation and signup controllers for better flow.
  (ccoleman@redhat.com)
- nav additions coming over from original _navbar (sgoodwin@redhat.com)
- fix header backgrounds, ie8 and chrome logo issues (sgoodwin@redhat.com)
- Display errors using formtastic, make login model driven
  (ccoleman@redhat.com)
- New forms are active everywhere (ccoleman@redhat.com)
- bug #802354 - disable details button for jenkins server (johnp@redhat.com)
- Bug 803854 - Remove https (ccoleman@redhat.com)
- Bug 790695 - User guide link broken (ccoleman@redhat.com)
- Bug 804177 - icons missing, visually unaligned (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/login (ccoleman@redhat.com)
- More cookies hacking, no success, give up and admin defeat.
  (ccoleman@redhat.com)
- Round out some remaining tests. Slight tweaks to behavior of :cookie_domain
  => :current Comment out unit tests related to cookies until I can debug
  (ccoleman@redhat.com)
- Fix duplicate constant error by making status site autoload
  (ccoleman@redhat.com)
- Merge branch 'master' into login (ccoleman@redhat.com)
- Remove useless file (ccoleman@redhat.com)
- Dealing with complexities of cookie handling in functional tests, whittling
  down dead code. (ccoleman@redhat.com)
- Additional tests, support referrer redirection (ccoleman@redhat.com)
- Merge branch 'master' into login (ccoleman@redhat.com)
- Further cleaning up login flow (ccoleman@redhat.com)
- Add more unit tests for cookie behavior (ccoleman@redhat.com)
- Incremental testing (ccoleman@redhat.com)
- Add configurable cookie domain for rh_sso (allow site to work outside of
  .redhat.com) Begin simplifying login flow (ccoleman@redhat.com)

* Sat Mar 17 2012 Dan McPherson <dmcphers@redhat.com> 0.89.1-1
- bump spec numbers (dmcphers@redhat.com)
- Capitalization of node.js (ccoleman@redhat.com)
- Feedback from Dan J about message (ccoleman@redhat.com)
- Reorganize cartridge page to avoid visual bugs, other minor arrangements
  (ccoleman@redhat.com)
- don't error out if server doesn't send back messages (johnp@redhat.com)
- Bug 803854 - bad URL for php my admin (ccoleman@redhat.com)
- Fixes 803934 (ffranz@redhat.com)

* Thu Mar 15 2012 Dan McPherson <dmcphers@redhat.com> 0.88.12-1
- when creating cart make sure to pass the server results back to the UI
  (johnp@redhat.com)
- Fixed embedding display (fotios@redhat.com)
- Cleaned up embedded cart listing (fotios@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Added more blocked type to scaled application and error message
  (fotios@redhat.com)
- Fixes 802713 (ffranz@redhat.com)
- Added support for scaling app to block certain embedded cartridges
  (fotios@redhat.com)
- Updated homepage copy based on Dan's feedback, disabled images until we can
  get styles. (ccoleman@redhat.com)
- Fixes 803674, improved terms layout (ffranz@redhat.com)
- Fixed form validation to be more consistant (fotios@redhat.com)
- fix cartridge_type index view to check if there are any carts to be displayed
  (johnp@redhat.com)
- Fixes 803665 (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 803212 (ffranz@redhat.com)
- mark the metrics cart as experimental and tag it in the UI (johnp@redhat.com)
- Merge branch 'devweb' (sgoodwin@redhat.com)
- including graphics on home and fix ie bugs (sgoodwin@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.11-1
- Simple header should not have text, move content (ccoleman@redhat.com)
- Minor cleanup to the getting started content - Flex is bare enough that we
  should axe it (ccoleman@redhat.com)
- Minor routes cleanup (ccoleman@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.10-1
- Fixed minLength for validations (fotios@redhat.com)
- Updated overview with new style commands and python package
  (ccoleman@redhat.com)
- Videos expand outside their boundaries when on a small device, temporary
  hac^Hfix (ccoleman@redhat.com)
- Added form validations (fotios@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.9-1
- 

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.8-1
- add requires and conflicts data to cart types and display (johnp@redhat.com)
- fix the phpmyadmin descriptor (johnp@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.7-1
- Added an inspector to watch an intermittent test failure (ffranz@redhat.com)
- Removed placeholder for application type image (fotios@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Merge branch 'devwed' (sgoodwin@redhat.com)
- new and improved header logo now with vitamin d (sgoodwin@redhat.com)
- Fixed streamline tests (ffranz@redhat.com)
- Fixes 803232 (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 803232; added new getting started pages; conditional take_action
  according to existing session (ffranz@redhat.com)
- Bug 802709 - some links on homepage broken (ccoleman@redhat.com)
- Added haproxy application_type so scaled apps show up (fotios@redhat.com)
- Add text comments from yesterday (ccoleman@redhat.com)
- Fixes 803223 - added proper captcha error messages (ffranz@redhat.com)
- site/site.spec: Fixed permissions not taking (whearn@redhat.com)
- Bug 803189 - using wrong layout when change password fails
  (ccoleman@redhat.com)
- Bug 803229, fixup email confirm page with new styles (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 802658 (ffranz@redhat.com)
- Need to force the URL for aliases (fotios@redhat.com)
- Fixed login_ajax_path missing (fotios@redhat.com)
- Moved jQuery to use CDN and commented on JS usage (fotios@redhat.com)
- Fixed broken unit tests (ccoleman@redhat.com)
- Fixes 803212: added more error messages on signup (ffranz@redhat.com)
- Improvements to login flow. Time to go to sleep. (ffranz@redhat.com)
- Fixed error messages on signin (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixed error messages on signin, signup and recover screens; added ribbon
  content support for the simple layout (ffranz@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.6-1
- Fixed box layout to simple layout on user and login controllers
  (ffranz@redhat.com)

* Tue Mar 13 2012 Dan McPherson <dmcphers@redhat.com> 0.88.5-1
- Had to switch away from 'span-wrapper' to 'grid-wrapper' to get the proper
  ordering.  Responsive is updated to take into account.  Community styles
  updated (ccoleman@redhat.com)
- Fix navigation bar styles for thick underlines, make clickable area larger.
  (ccoleman@redhat.com)
- Give tiny highlight behavior to take action (ccoleman@redhat.com)
- Show openshift tweets until we have recommendation content For login page
  show a button that is not btn-primary (allow form to override btn-primary)
  (ccoleman@redhat.com)
- Switch to grid based column layout, fix problems with offset* and span-
  wrapper in various scenarios (ccoleman@redhat.com)
- More tweaks to layout and controllers (ccoleman@redhat.com)
- Stylesheets (ccoleman@redhat.com)
- Clean up references (ccoleman@redhat.com)
- Rename 'box' layout to 'simple', collapse references to both Add
  SiteController as a parent controller for controllers that are specific to a
  specific side of the site (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes login flow bugs (ffranz@redhat.com)
- Change multi-element ribbon headers to single element headers
  (edirsh@redhat.com)
- Add styling for single-element ribbonw (edirsh@redhat.com)
- home callout styling (sgoodwin@redhat.com)
- Detect currently active tab in header navigation (fotios@redhat.com)
- Reverse order of buttons in the ui (ccoleman@redhat.com)
- Failing unit test caused by change in logout logic (ccoleman@redhat.com)
- Bug 802732 - was not merging errors correctly in applications_controller.
  Added some debug logging for future. (ccoleman@redhat.com)
- Temporarily fix stylesheet issues with help-block being turned to a color
  (and thus confusing users about whether the help is an error).
  (ccoleman@redhat.com)
- Allow aliased errors to be reported correctly for their originating attribute
  (ccoleman@redhat.com)
- Remove comments for now, no confusion (ccoleman@redhat.com)
- Add better logging to certain filters (ccoleman@redhat.com)
- Unit test updates (ccoleman@redhat.com)
- Merge branch 'devtues' (sgoodwin@redhat.com)
- detailing buzz section and other minor things home related
  (sgoodwin@redhat.com)
- add unit test for cartridges model (johnp@redhat.com)
- Various login tweaks to work around limitations from RHN
  (ccoleman@redhat.com)
- Make ID based rules class based (ccoleman@redhat.com)
- fine tuning navbar (sgoodwin@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes login flows tests (ffranz@redhat.com)

* Mon Mar 12 2012 Dan McPherson <dmcphers@redhat.com> 0.88.4-1
- Removed login flow tests, starting to integrate with the new login flow
  (ffranz@redhat.com)
- Fixes old control_panel test (ffranz@redhat.com)
- Fixes some test failures on login flows (ffranz@redhat.com)
- Fixed user_controller tests that requires create.html.haml
  (ffranz@redhat.com)
- Fixes signup success page (ffranz@redhat.com)
- Branding: old control_panel and dashboard routes redirects to /console
  (ffranz@redhat.com)
- Branding: removed the temporary /new controller route (ffranz@redhat.com)
- Fixed signup redirect bug (ffranz@redhat.com)
- Fixed login redirect bug (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixed login redirect bug (ffranz@redhat.com)
- focus states for primary nav (sgoodwin@redhat.com)
- Branding: fixed broken images, adjust routes for the good of SEO
  (ffranz@redhat.com)
- Branding: improved login page (ffranz@redhat.com)
- Branding: improved login page (ffranz@redhat.com)
- Overview typo, remove max-height (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Branding: links on signin, signup, recover pages (ffranz@redhat.com)
- Fixed workflow for signup form (fotios@redhat.com)
- updated comment thread styles (sgoodwin@redhat.com)
- Branding: improved Express and Flex pages (ffranz@redhat.com)
- Branding: merged header (ffranz@redhat.com)
- section-top color changes (sgoodwin@redhat.com)
- Fix links in between overview and content (ccoleman@redhat.com)
- Integrate overview site (ccoleman@redhat.com)
- Regeneration of home/common with merges (ccoleman@redhat.com)
- Reenable btn-primary for commit buttons (ccoleman@redhat.com)
- Update cartridge landing page styles (ccoleman@redhat.com)
- Styleguide example of landing page (ccoleman@redhat.com)
- Branding: getting started page (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Branding: partners pages (ffranz@redhat.com)
- add cartridge_types functional tests (johnp@redhat.com)
- add bridge styling for simple page (edirsh@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Branding: videos pages (ffranz@redhat.com)
- make sure we have a leading slash when concatting rest urls
  (johnp@redhat.com)
- cartridges functional test (johnp@redhat.com)
- Branding: Flex page (ffranz@redhat.com)
- Branding: legal pages (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Merge branch 'devmon' (sgoodwin@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Branding: integrating everything into current site (hold on your seat)
  (ffranz@redhat.com)
- checking in compiled stylesheet (edirsh@redhat.com)
- Further tweaks to large backgrounds (edirsh@redhat.com)
- cleanup odds and ends (sgoodwin@redhat.com)
- Update help link to app cli management (ccoleman@redhat.com)
- Make create app a button (ccoleman@redhat.com)
- Comment out videos for this sprint, will deal with in a follow up
  (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Branding: signup confirmation page (ffranz@redhat.com)
- Regen CSS after merge (ccoleman@redhat.com)
- New logo for status site, some minor css tweaks for now.
  (ccoleman@redhat.com)
- Update font family to match global variable (ccoleman@redhat.com)
- section-top bar mods (sgoodwin@redhat.com)
- newletter signup edit (sgoodwin@redhat.com)
- ui tweaks (sgoodwin@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Branding: recover password workflow (ffranz@redhat.com)
- touch icons (sgoodwin@redhat.com)
- Update logo for console site to match branding guidelines (roughly), still
  needs lots of love. (ccoleman@redhat.com)

* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.88.3-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Branding: signin, signup and recover pwd now on smaller boxes and dedicated
  pages (ffranz@redhat.com)

* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.88.2-1
- Branding: signin, signup and recover pwd now on smaller boxes and dedicated
  pages (ffranz@redhat.com)
- Changed background styling for small screens (edirsh@redhat.com)
- Tweaked background styles for home page; added bg styles for interior and
  community pages (edirsh@redhat.com)
- Updated #search-field to use a marker class, added styles for votes, videos,
  and rudimentary KB articles. (ccoleman@redhat.com)
- Merge branch 'dev/kraman/US1972' (kraman@gmail.com)
- Moved font code to its own CSS for better loading (fotios@redhat.com)
- Rename 'take-action' to 'action-call' and add 'action-more' for secondary
  links.  Update styles for blog to match. (ccoleman@redhat.com)
- Branding: styling signup page (ffranz@redhat.com)
- Updates for getting devenv running (kraman@gmail.com)
- Renaming Cloud-SDK -> StickShift (kraman@gmail.com)
- Branding: signin page (ffranz@redhat.com)
- Mark old partials as obsolete (ccoleman@redhat.com)
- Mark style.scss as out of date so it is no longer generated, and ignore any
  .sass-cache directories created (ccoleman@redhat.com)
- Site css files (ccoleman@redhat.com)
- font size tweaks (sgoodwin@redhat.com)
- Merge branch 'dev309' (sgoodwin@redhat.com)
- avatar and type edits (sgoodwin@redhat.com)
- Added Overview and Flex sections to homepage header (ffranz@redhat.com)
- Fixed Firefox desaturation of the logo by removing the color profile from the
  PNG (ccoleman@redhat.com)
- sprite change (sgoodwin@redhat.com)
- Merge branch 'dev308' (sgoodwin@redhat.com)
- secondary navigation modifications (sgoodwin@redhat.com)
- Reorganization of navbar styles for console, minor hacks to get an
  approximate look for the old console.  More to come (ccoleman@redhat.com)
- when listing available carts show installed carts but disable selection
  (johnp@redhat.com)
- Chrome/webkit prefixed properties, fix minor bugs with gradients
  (ccoleman@redhat.com)
- Add rdiscount markdown support (ccoleman@redhat.com)
- Add more metadata to the cartridges in the CartridgeType model
  (johnp@redhat.com)
- Branding: added Express and Flex sections (ffranz@redhat.com)
- fix up the next steps page for carts wizard (johnp@redhat.com)
- next steps template file (johnp@redhat.com)
- next_steps wizard page for successful cart creation (johnp@redhat.com)
- Fix for getting hostname on prod/stg servers (fotios@redhat.com)
- Merge branch 'responsive' (ccoleman@redhat.com)
- Fix some responsive bugs at 768px (exactly), balance messaging font sizes in
  portrait mode, keep refining code (ccoleman@redhat.com)
- Fixes user controller missing routes (ffranz@redhat.com)
- Branding: added site controller, adjusted missing layout on legacy pages
  (ffranz@redhat.com)
- Branding: signin page and conditional headers according to existing session
  (ffranz@redhat.com)
- Branding: new signup page (ffranz@redhat.com)
- Integrate backgrounds directly, work around lack of compass for now by
  inlining after generation. Fix header colors Fix fonts to let Helvetica
  override Liberation Sans Letter spacing on check the buzz
  (ccoleman@redhat.com)
- Start abstracting colors into variables (ccoleman@redhat.com)
- Sign in link and header color (ccoleman@redhat.com)
- Allow views to pass classes to nav header for lifting (ccoleman@redhat.com)
- Give sections bottom margin, left align take-action in responsive mode, magic
  (ccoleman@redhat.com)
- Simplify take-action section, allow it to be used in nav and in content body,
  provide helper method, fix problems with responsive layout
  (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Branding: basic signup content, home header styling (ffranz@redhat.com)
- Add styles and images for homepage buzz section (edirsh@redhat.com)
- Add styling and images for new branding homepage header (edirsh@redhat.com)
- redirect on successful addition of cart (johnp@redhat.com)
- workarounds to using 'type' as a model field in the rest api
  (johnp@redhat.com)
- Branding: styling background images (ffranz@redhat.com)
- Branding new home CSS styling (ffranz@redhat.com)
- Branding new home CSS styling (ffranz@redhat.com)
- More responsive tweaks to take action bar (ccoleman@redhat.com)
- Favicons, headers, grid fixes for iphone and small devices, restore a minor
  merge conflict (ccoleman@redhat.com)
- New branding on homepage, added twitter buzz (ffranz@redhat.com)
- fixed cartridge model encoding issue (johnp@redhat.com)
- list style edit (sgoodwin@redhat.com)
- add the bones around adding a cart to an application (johnp@redhat.com)
- New branding for the home page (ffranz@redhat.com)
- Accidentally reenabled markdown too early (ccoleman@redhat.com)
- Add wrapper node for left column to give it a margin (Gnhhh, so many
  wrappers.  Damn you grid) Poll styles Images for expand collapse Comment
  style cleanup Simplification of links (ccoleman@redhat.com)
- overview page, fixes to header, minus markdown requirements.
  (ccoleman@redhat.com)
- Add headline marker class to primary messaging (ccoleman@redhat.com)
- Community tweaks (ccoleman@redhat.com)
- Add badges and some generic cleanup to comments (ccoleman@redhat.com)
- search block modifications (sgoodwin@redhat.com)
- revert an errant commit to development config file (johnp@redhat.com)
- Update tabs, update header (ccoleman@redhat.com)
- Minor tweaks to header to accomodate possible animation, fix problems at
  smaller resolutions (ccoleman@redhat.com)
- add show template for cartridge types (johnp@redhat.com)
- Add subheadings and some minor style tweaks to the help page
  (ccoleman@redhat.com)
- hook up the show cartridge_type action for adding cartridges
  (johnp@redhat.com)
- get cart list from rest api but fill in details in the model
  (johnp@redhat.com)
- Merge branch 'dev/clayton/help' (ccoleman@redhat.com)
- Marker class for styles (ccoleman@redhat.com)
- More fixup of help links (ccoleman@redhat.com)
- Proto help page (ccoleman@redhat.com)
- add links to add a cartridge (johnp@redhat.com)
- add initial page for cartridge selection (johnp@redhat.com)
- move wizard_create helper to app_wizard_create and add cartridge wizard
  (johnp@redhat.com)
- Fixes 799188: will remove Node.JS from the list of available cartridges in
  production (ffranz@redhat.com)
- Fixes 799188: will remove Node.JS from the list of available cartridges in
  production (ffranz@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mpatel@redhat.com)
- Changes to rename raw to diy. (mpatel@redhat.com)
- Layout with header content (ccoleman@redhat.com)
- Remove unused stylesheet, unused controller bit (ccoleman@redhat.com)
- Use relative links in CSS (ccoleman@redhat.com)
- sprite additions (sgoodwin@redhat.com)
- Logo integration (ccoleman@redhat.com)
- Merge branch 'master' of git:/srv/git/li (ccoleman@redhat.com)
- Add active colors for menu, ensure submenus have the right margins enter the
  commit message for your changes. Lines starting (ccoleman@redhat.com)
- Fix for BZ799561: rhc-outage now correctly identifies sync failures
  (fotios@redhat.com)
- Reenable node.js (ccoleman@redhat.com)
- Fix ordering of stylesheets on examples (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/home (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/home (ccoleman@redhat.com)
- Right facing arrow (ccoleman@redhat.com)
- Start on creating a layout for the new styles (ccoleman@redhat.com)
- Rename constants (ccoleman@redhat.com)
- Fix up menu padding (ccoleman@redhat.com)
- Begin reorganizing site.scss into partials (ccoleman@redhat.com)
- More tweaks to navigation and headers (ccoleman@redhat.com)
- Signup (ccoleman@redhat.com)
- Much simpler solution for grid filling (introduction of row-flush-right and
  span-wrapper) to allow backgrounds to fit content more cleanly
  (ccoleman@redhat.com)

* Fri Mar 02 2012 Dan McPherson <dmcphers@redhat.com> 0.88.1-1
- bump spec numbers (dmcphers@redhat.com)
- Had to fix the view too (fotios@redhat.com)
- Fixed static routes in status app (fotios@redhat.com)
- Refactored status_app to work with different Rails app_scopes
  (fotios@redhat.com)
- Reword text to match recommendations from dblado (ccoleman@redhat.com)
- Fixes 799503 (ffranz@redhat.com)
- Adjust base_domain configuration for stg and prod (ffranz@redhat.com)
- Merge branch 'master' into dev/clayton/home (ccoleman@redhat.com)
- Disable node.js 799188 (ccoleman@redhat.com)
- More comment tweaks (ccoleman@redhat.com)
- Minor tweaks to comments (ccoleman@redhat.com)
- Reorder try it out to be better (ccoleman@redhat.com)
- Pixel-perfect layout adjustments (ffranz@redhat.com)
- Fixed gutters to be more accurate within various resolutions, lines up
  exactly with ipad screen. (ccoleman@redhat.com)
- Fixes 798142, major app list style improvements (ffranz@redhat.com)
- sprite img (sgoodwin@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- Fixes 798502: added links to docs (ffranz@redhat.com)
- Removed switch to use attr in %%files instead of chmod Mark hosts.yml as
  config(noreplace) (whearn@redhat.com)
- More changes to styling of community (ccoleman@redhat.com)
- Comments, various small tweaks to community CSS (ccoleman@redhat.com)
- Tweets, block quotes, some padding adjustments, default link colors, and
  background with repeating gradient. (ccoleman@redhat.com)
- Merge branch 'master' into dev/clayton/home (ccoleman@redhat.com)
- Merge of bootstrap (ccoleman@redhat.com)
- Styles for homepage (ccoleman@redhat.com)

* Thu Mar 01 2012 Dan McPherson <dmcphers@redhat.com> 0.87.13-1
- Fixed link for user guide to point to html version (fotios@redhat.com)

* Thu Mar 01 2012 Dan McPherson <dmcphers@redhat.com> 0.87.12-1
- Bug 798854 - some error messages were eaten because each block didn't return
  the same value for the block. (ccoleman@redhat.com)

* Wed Feb 29 2012 Dan McPherson <dmcphers@redhat.com> 0.87.11-1
- move to application layout since simple isn't ready (johnp@redhat.com)
- Add mthompso@redhat.com to promo mailing list (ccoleman@redhat.com)
- switch to simple layout for password reset (johnp@redhat.com)
- show errors (johnp@redhat.com)
- make sure streamline return the correct result when resetting password
  (johnp@redhat.com)
- render password reset with the correct layout (johnp@redhat.com)
- Another fix for BZ796075 (fotios@redhat.com)
- Fix for BZ796075. Moved _console.scss -> console.scss to reduce confusion,
  since its not a partial. Removed left over import in _responsive.scss to
  unbreak (fotios@redhat.com)
- styles to force word-wrap when needed (sgoodwin@redhat.com)
- fix wrong cased OpenShift (dmcphers@redhat.com)
- Merge branch 'master' of git:/srv/git/li (ccoleman@redhat.com)
- Loading icon not being displayed on staging (bad URL), and overly aggressive
  string aggregation in error messages leads to bad text.  Bug 797747
  (ccoleman@redhat.com)
- Breadcrumbs matching style (ccoleman@redhat.com)

* Tue Feb 28 2012 Dan McPherson <dmcphers@redhat.com> 0.87.10-1
- add an id to the control group so sauce can check for error conditions
  (johnp@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Integrated app details page to new console markup and css (ffranz@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Bug 797296 - [REST API] API allowed creation of key with 8000 character name
  (lnader@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (ffranz@redhat.com)
- add class and id markup so sauce tests can easily find elements
  (johnp@redhat.com)
- Integrated app details page to new console markup and css (ffranz@redhat.com)
- Bug 797296 - [REST API] API allowed creation of key with 8000 character name
  (lnader@redhat.com)
- Bug 797296 - [REST API] API allowed creation of key with 8000 character name
  (lnader@redhat.com)
- Integrated app details page to new console markup and css (ffranz@redhat.com)
- bug 798128 fix (sgoodwin@redhat.com)
- console css edit (sgoodwin@redhat.com)
- console updates (sgoodwin@redhat.com)
- Integrating markup and style for the new console (ffranz@redhat.com)
- Check in change to bootstrap (ccoleman@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.9-1
- Added correct permissions for status site (fotios@redhat.com)

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
