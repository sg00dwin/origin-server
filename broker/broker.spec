%define htmldir %{_localstatedir}/www/html
%define brokerdir %{_localstatedir}/www/stickshift/broker

Summary:   Li broker components
Name:      rhc-broker
Version: 0.96.11
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-broker-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-server-common
Requires:  httpd
Requires:  mod_ssl
Requires:  mod_passenger
Requires:  rubygem-json
Requires:  rubygem-parseconfig
Requires:  rubygem-passenger-native-libs
Requires:  rubygem-rails
Requires:  rubygem-xml-simple
Requires:  rubygem-stickshift-controller
Requires:  rubygem-bson_ext
Requires:  rubygem-rest-client
Requires:  rubygem-thread-dump
Requires:  rubygem-swingshift-streamline-plugin
Requires:  rubygem-uplift-dynect-plugin
Requires:  rubygem-gearchanger-mcollective-plugin
#Requires:  rubygem-term-ansicolor
#Requires:  rubygem-trollop
#Requires:  rubygem-cucumber
#Requires:  rubygem-gherkin
Requires:  rubygem(ruby-prof)
Requires:  rubygem-ruby-prof
Requires:  rubygem-rcov
Requires:  rubygem-mongo_mapper
Requires:  rubygem-wddx
Requires:  rubygem-pony
Requires:  mcollective-qpid-plugin

BuildArch: noarch

%description
This contains the broker 'controlling' components of OpenShift.
This includes the public APIs for the client tools.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{brokerdir}
mkdir -p %{buildroot}/usr/lib/stickshift/broker
mv application_templates %{buildroot}/usr/lib/stickshift/broker
cp -r . %{buildroot}%{brokerdir}
ln -s %{brokerdir}/public %{buildroot}%{htmldir}/broker

mkdir -p %{buildroot}%{brokerdir}/run
mkdir -p %{buildroot}%{brokerdir}/log
mkdir -p %{buildroot}%{_localstatedir}/log/stickshift

mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-domain %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-app %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-cartridge-do %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-migrate %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-move %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-district %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-template %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-usage %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-user %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-chk %{buildroot}/%{_bindir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0640,root,libra_user,0750)
%ghost %{brokerdir}/log/production.log
%ghost %{_localstatedir}/log/stickshift/user_action.log
%config(noreplace) %{brokerdir}/config/environments/production.rb
%config(noreplace) %{brokerdir}/config/keys/public.pem
%config(noreplace) %{brokerdir}/config/keys/private.pem
%attr(0600,-,-) %config(noreplace) %{brokerdir}/config/keys/rsync_id_rsa
%config(noreplace) %{brokerdir}/config/keys/rsync_id_rsa.pub
%attr(0750,-,-) %{brokerdir}/config/keys/generate_rsa_keys
%attr(0750,-,-) %{brokerdir}/config/keys/generate_rsync_rsa_keys
%attr(0750,-,-) %{brokerdir}/script
%{brokerdir}
%{htmldir}/broker
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-domain
%attr(0750,-,-) %{_bindir}/rhc-admin-chk
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-app
%attr(0750,-,-) %{_bindir}/rhc-admin-cartridge-do
%attr(0750,-,-) %{_bindir}/rhc-admin-migrate
%attr(0750,-,-) %{_bindir}/rhc-admin-move
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-district
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-template
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-usage
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-user
/usr/lib/stickshift/broker/application_templates

%post
/bin/touch %{brokerdir}/log/production.log
/bin/touch %{_localstatedir}/log/stickshift/user_action.log

%changelog
* Mon Jul 30 2012 Dan McPherson <dmcphers@redhat.com> 0.96.11-1
- Updating gem versions (dmcphers@redhat.com)
- Bug 844276 (dmcphers@redhat.com)
- Merge pull request #58 from fotioslindiakos/remove_rails_test_template
  (fotioslindiakos@gmail.com)
- Removing Rails test template (fotios@redhat.com)
- Bug 844286 (dmcphers@redhat.com)
- switch from user uuid to MD5 for aria id (dmcphers@redhat.com)
- Bug 844238 (dmcphers@redhat.com)

* Fri Jul 27 2012 Dan McPherson <dmcphers@redhat.com> 0.96.10-1
- Updating gem versions (dmcphers@redhat.com)
- Merge pull request #139 from nhr/hiding_django (fotioslindiakos@gmail.com)
- Setting Django template to 'in_development' (hripps@redhat.com)
- Merge pull request #134 from pravisankar/dev/ravi/story/2555-cleanup
  (kraman@gmail.com)
- Fix for BugZ#843818: Add a template without '-t' parameter (tags) leads to an
  error (kraman@gmail.com)
- Added subaccount inheritance testcase and cloud9 cleanup (rpenta@redhat.com)

* Fri Jul 27 2012 Dan McPherson <dmcphers@redhat.com> 0.96.9-1
- Updating gem versions (dmcphers@redhat.com)

* Fri Jul 27 2012 Dan McPherson <dmcphers@redhat.com> 0.96.8-1
- Updating gem versions (dmcphers@redhat.com)

* Thu Jul 26 2012 Dan McPherson <dmcphers@redhat.com> 0.96.7-1
- Updating gem versions (dmcphers@redhat.com)
- Merge pull request #129 from rmillner/dev/rmillner/bugs/842977
  (dmcphers@redhat.com)
- Add mysql and mongodb type gears to migration. (rmillner@redhat.com)
- Merge pull request #128 from nhr/templates (fotioslindiakos@gmail.com)
- Fixed descriptors for test templates (hripps@redhat.com)
- Merge pull request #124 from pravisankar/dev/ravi/story/2555
  (kraman@gmail.com)
- Merge pull request #126 from nhr/templates (fotioslindiakos@gmail.com)
- Added templates for CakePHP and Django (hripps@redhat.com)
- Remove 'vip' from user model and other scripts (rpenta@redhat.com)
- Adding blacklisted words (kraman@gmail.com)
- minor cleanup (dmcphers@redhat.com)
- US2397 (dmcphers@redhat.com)

* Tue Jul 24 2012 Adam Miller <admiller@redhat.com> 0.96.6-1
- Updating gem versions (admiller@redhat.com)
- Renamed 'send' calls to 'request' as per rhc change. (hripps@redhat.com)
- Merge pull request #104 from pravisankar/dev/ravi/billing_fix_testcase
  (lnader@redhat.com)
- Fix billing functional test (rpenta@redhat.com)

* Fri Jul 20 2012 Adam Miller <admiller@redhat.com> 0.96.5-1
- Updating gem versions (admiller@redhat.com)
- Merge pull request #101 from lnader/master (rpenta@redhat.com)
- fix typo (dmcphers@redhat.com)
- Billing Rest API and bug 841058 (lnader@redhat.com)
- Merge pull request #100 from pravisankar/dev/ravi/billing_fix_exception
  (lnader@redhat.com)
- Bug 841073 (dmcphers@redhat.com)
- Added aria_billing.rb so that rails can *explicitly* pick up Aria::Billing::*
  classes (rpenta@redhat.com)
- Merge pull request #99 from tkramer-rh/dev/tkramer/broker/log_acl
  (admiller@redhat.com)
- Security - remove Other perms from production.log and user_action.log
  (tkramer@redhat.com)

* Thu Jul 19 2012 Adam Miller <admiller@redhat.com> 0.96.4-1
- Updating gem versions (admiller@redhat.com)

* Thu Jul 19 2012 Adam Miller <admiller@redhat.com> 0.96.3-1
- Updating gem versions (admiller@redhat.com)
- Bug 841032 (dmcphers@redhat.com)
- Revert the following commit IDs because they broke the build
  (admiller@redhat.com)
- corrected syntax error in test (lnader@redhat.com)
- Merge pull request #87 from lnader/master (rpenta@redhat.com)
- broker sanity test reorg (dmcphers@redhat.com)
- added checking to see if user is being downgraded (lnader@redhat.com)
- incorporated changes from pull request review (lnader@redhat.com)
- disable teardown when tests are disabled (lnader@redhat.com)
- US2427: Broker add / change plan REST API (lnader@redhat.com)
- Merge pull request #72 from fotioslindiakos/rhc_admin_ctl_template
  (kraman@gmail.com)
- add rhc-accept-devenv (dmcphers@redhat.com)
- Added ability to remove templates by name or multiple uuids/names
  (fotios@redhat.com)

* Fri Jul 13 2012 Adam Miller <admiller@redhat.com> 0.96.2-1
- Updating gem versions (admiller@redhat.com)
- update migration to 2.0.15 and add better config for migration
  (dmcphers@redhat.com)
- Fixing template generation (fotios@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.96.1-1
- Updating gem versions (admiller@redhat.com)
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.95.21-1
- Updating gem versions (admiller@redhat.com)
- added mcollective-qpid-plugin as a dep to rhc-broker rpm
  (admiller@redhat.com)
- Merge pull request #55 from fotioslindiakos/bson_fix (ccoleman@redhat.com)
- Merge pull request #54 from rmillner/dev/rmillner/bug/832747
  (jwhonce@gmail.com)
- More fixes for proper serialization (fotios@redhat.com)
- Fixed serialization of nested hashes (fotios@redhat.com)
- Regenerated descriptors with new code (fotios@redhat.com)
- Added functions to deploy.rb to ensure it can parse the YAML::Omap properly
  (fotios@redhat.com)
- Added support to parse the BSON coming back from the broker
  (fotios@redhat.com)
- New rpc options created without using a large enough timeout.
  (rmillner@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.95.20-1
- Updating gem versions (admiller@redhat.com)

* Tue Jul 10 2012 Adam Miller <admiller@redhat.com> 0.95.19-1
- Updating gem versions (admiller@redhat.com)
- Add missing config. (mpatel@redhat.com)
- Bug 838831 - Simplify enable/disable-sso for all teams (ccoleman@redhat.com)

* Tue Jul 10 2012 Adam Miller <admiller@redhat.com> 0.95.18-1
- Updating gem versions (admiller@redhat.com)

* Mon Jul 09 2012 Adam Miller <admiller@redhat.com> 0.95.17-1
- Updating gem versions (admiller@redhat.com)

* Mon Jul 09 2012 Adam Miller <admiller@redhat.com> 0.95.16-1
- Updating gem versions (admiller@redhat.com)

* Mon Jul 09 2012 Adam Miller <admiller@redhat.com> 0.95.15-1
- Updating gem versions (admiller@redhat.com)

* Mon Jul 09 2012 Dan McPherson <dmcphers@redhat.com> 0.95.14-1
- Updating gem versions (dmcphers@redhat.com)

* Mon Jul 09 2012 Dan McPherson <dmcphers@redhat.com> 0.95.13-1
- Merge pull request #30 from fabianofranz/master (ccoleman@redhat.com)
- Merged application templates (contact@fabianofranz.com)
- Regenerated springeap6/descriptor.yaml (contact@fabianofranz.com)
- Adjusted broker/application_templates/templates/deploy.rb with YAML generated
  by Ruby 1.9 (contact@fabianofranz.com)
- Recreated deploy.rb for app templates (contact@fabianofranz.com)
- Added Spring Framework on JBoss EAP6 template (contact@fabianofranz.com)

* Mon Jul 09 2012 Dan McPherson <dmcphers@redhat.com> 0.95.12-1
- Updating gem versions (dmcphers@redhat.com)
- Merge pull request #29 from abhgupta/abhgupta-dev (kraman@gmail.com)
- Merge pull request #33 from fotioslindiakos/rails32_template
  (ccoleman@redhat.com)
- fixing libra_extended - bug in one of the newly added tests
  (abhgupta@redhat.com)
- Fixed deploy.rb (fotios@redhat.com)
- Removed new metadata fields (fotios@redhat.com)
- fix for bug#837574 - vip user cannot create medium gear (rchopra@redhat.com)
- Adding test Rails template that points to my master branch for Rails
  quickstart (fotios@redhat.com)
- Modified Rails template to use Ruby 1.9 and Rails 3.2.6 (fotios@redhat.com)

* Fri Jul 06 2012 Adam Miller <admiller@redhat.com> 0.95.11-1
- Updating gem versions (admiller@redhat.com)

* Thu Jul 05 2012 Adam Miller <admiller@redhat.com> 0.95.10-1
- fixed Gemfile.lock (admiller@redhat.com)

* Thu Jul 05 2012 Adam Miller <admiller@redhat.com> 0.95.9-1
- Updating gem versions (admiller@redhat.com)
- adding rake system-level tests (abhgupta@redhat.com)
- Fix Gemfile.lock to match version in tag. (mpatel@redhat.com)

* Tue Jul 03 2012 Adam Miller <admiller@redhat.com> 0.95.8-1
- fix typo for Gemfile.lock in broker (admiller@redhat.com)

* Tue Jul 03 2012 Adam Miller <admiller@redhat.com> 0.95.7-1
- Add missing systemu dependency. (mpatel@redhat.com)

* Tue Jul 03 2012 Adam Miller <admiller@redhat.com> 0.95.6-1
- Updating gem versions (admiller@redhat.com)
- Fix broker Gemfile.lock to use correct plugin. (mpatel@redhat.com)
- Fix the dependency to correct plugin. (mpatel@redhat.com)
- Fix invalid args. (mpatel@redhat.com)
- Fixes. (mpatel@redhat.com)
- WIP changes to support mcollective 2.0. (mpatel@redhat.com)
- Refactoring out express specific code from mcollective. (mpatel@redhat.com)

* Mon Jul 02 2012 Adam Miller <admiller@redhat.com> 0.95.5-1
- Updating gem versions (admiller@redhat.com)
- Add the 180s timeout to devenv as well. (rmillner@redhat.com)
- Merge pull request #14 from rmillner/dev/rmillner/bug/832747
  (rpenta@redhat.com)
- Merge pull request #15 from pravisankar/master (rpenta@redhat.com)
- billing event changes (rpenta@redhat.com)
- minor fix in billing events (rpenta@redhat.com)
- Revert "Updating gem versions" (dmcphers@redhat.com)
- Billing event changes: RHLogin info in account data section and add
  supplemental fields to each event notification (rpenta@redhat.com)
- Billing: Added get_acct_plans_all() api (rpenta@redhat.com)
- Observing rpc timeouts of otherwise successful operations when there's a high
  IO or CPU load.  The jbossas-7 configure hook takes 30 seconds on an
  otherwise idle system; heavy IO can easily double or triple the cost of the
  hook.  Making the timeout higher to compensate. (rmillner@redhat.com)
- Updating gem versions (admiller@redhat.com)
- update migration for 2.0.14 (dmcphers@redhat.com)
- update streamline ip (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.95.4-1
- Updating gem versions (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.95.3-1
- new package built with tito

* Thu Jun 21 2012 Adam Miller <admiller@redhat.com> 0.95.2-1
- Updating gem versions (admiller@redhat.com)
- Need to add active_support to templates rake script (fotios@redhat.com)

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 0.95.1-1
- Updating gem versions (admiller@redhat.com)
- Updating gem versions (admiller@redhat.com)
- bump_minor_versions for sprint 14 (admiller@redhat.com)

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 0.94.17-1
- Updating gem versions (admiller@redhat.com)
- cleanup (dmcphers@redhat.com)
- don't restart jenkins twice (bdecoste@gmail.com)
- added jenkins httpd proxy migrate to rhc-admin-migrate (bdecoste@gmail.com)
- Billing event notification changes:  - Removed event:120  - Include
  supplemental fields in 'Account Data' section  - Event:105 notification will
  be send only if status cd: active or suspended or cancelled or terminated  -
  Format change for sections: Supplemental plans, Supplemental Fields and
  Events (rpenta@redhat.com)

* Tue Jun 19 2012 Adam Miller <admiller@redhat.com> 0.94.16-1
- Updating gem versions (admiller@redhat.com)
- move migrate to the broker (dmcphers@redhat.com)
- BugFix: 833372 (rpenta@redhat.com)
- Billing:Fix record_usage api (rpenta@redhat.com)
- Fix for bug#833331 (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Billing: Fix broker enablement unit tests (rpenta@redhat.com)
- BZ828116: Added logic for displaying credentials for applications created
  from templates (fotios@redhat.com)
- was missing listsubaccounts option in the usage info for rhc-admin-ctl-user
  (abhgupta@redhat.com)

* Tue Jun 19 2012 Adam Miller <admiller@redhat.com> 0.94.15-1
- Updating gem versions (admiller@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Billing: Restrict '/broker/billing/*' URI access to Aria IP address range:
  64.238.195.110 to 64.238.195.125 (rpenta@redhat.com)

* Mon Jun 18 2012 Adam Miller <admiller@redhat.com> 0.94.14-1
- Updating gem versions (admiller@redhat.com)
- Billing: Remove MegaShift plan in production.rb for safety
  (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Billing: minor fix (rpenta@redhat.com)
- Billing: return supplemental field 'RHLogin' as userid (rpenta@redhat.com)
- Billing: Unit tests for billing events (rpenta@redhat.com)
- Billing: Added more aria api methods + some cleanup (rpenta@redhat.com)
- Billing config: Added supplemental plan + name change: plan_id to id
  (rpenta@redhat.com)

* Fri Jun 15 2012 Dan McPherson <dmcphers@redhat.com> 0.94.13-1
- Updating gem versions (dmcphers@redhat.com)

* Fri Jun 15 2012 Adam Miller <admiller@redhat.com> 0.94.12-1
- Updating gem versions (admiller@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Bug 832500 (dmcphers@redhat.com)
- billing error handling (dmcphers@redhat.com)
- Billing: classify notification either order or people info
  (rpenta@redhat.com)

* Thu Jun 14 2012 Adam Miller <admiller@redhat.com> 0.94.11-1
- Updating gem versions (admiller@redhat.com)
- search for existing usage before retrying (dmcphers@redhat.com)
- Billing: Event notification changes (rpenta@redhat.com)
- live without acct no for now (dmcphers@redhat.com)
- api to change master plan. function test capturing enablement lifecycle
  (rchopra@redhat.com)
- use aria userid as user's uuid (rchopra@redhat.com)
- usage work in progress (dmcphers@redhat.com)
- Added integration tests to test sub-user functionality (kraman@gmail.com)
- enable broker changes (rchopra@redhat.com)
- Billing: fixes (rpenta@redhat.com)
- Update broker Gemfile.lock (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Adding Cloud 9 settings template to non-dev environment configs for Broker
- Adding capabilities to cloud_user when it is created changes to admin script
  to manage sub accounts and capabilities changes to Mcollective application
  container proxy to include gear_sizes specified using capabilities for a user
  Cloud 9 config added to development environment Added c9 gear profile to
  district admin script changes to rhc-admil-ctl-user to validate input gear
  size
- Billing:Added Aria api (rpenta@redhat.com)
- remove unnecessary files (rpenta@redhat.com)
- Re-origanize aria billing helpers (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Merge billing code into broker (rpenta@redhat.com)

* Wed Jun 13 2012 Adam Miller <admiller@redhat.com> 0.94.10-1
- Updating gem versions (admiller@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 0.94.9-1
- Updating gem versions (admiller@redhat.com)
- enable usage tracking by default for test and dev (dmcphers@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 0.94.8-1
- Updating gem versions (admiller@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> 0.94.7-1
- Updating gem versions (admiller@redhat.com)
- Updated Gemfile.lock from running broker. (rmillner@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> 0.94.6-1
- remove requires aws-sdk, these apparently don't actually need it
  (admiller@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> 0.94.5-1
- Updating gem versions (admiller@redhat.com)
- Strip out the unnecessary gems from rcov reports and focus it on just the
  OpenShift code. (rmillner@redhat.com)
- move test collections to be separate (dmcphers@redhat.com)

* Fri Jun 08 2012 Adam Miller <admiller@redhat.com> 0.94.4-1
- Updating gem versions (admiller@redhat.com)
- fix for bug#827635 (rchopra@redhat.com)

* Fri Jun 08 2012 Adam Miller <admiller@redhat.com> 0.94.3-1
- Updating gem versions (admiller@redhat.com)
- use distributed lock from ctl-usage (dmcphers@redhat.com)
- adding basic distributed locking mechanism (dmcphers@redhat.com)
- Revert "BZ824124 remove unused doc_root connector" (jhonce@redhat.com)
- BZ824124 remove unused doc_root connector (jhonce@redhat.com)
- Updated gem info for rails 3.0.13 (admiller@redhat.com)
- Template profiling  * Added active total time to  * Removed metadata and
  individual create scripts  * Updated descriptors to ensure there were no
  changes (fotioslindiakos@gmail.com)
- Added ability to test git based templates (instead of descriptor based)
  (fotioslindiakos@gmail.com)

* Mon Jun 04 2012 Adam Miller <admiller@redhat.com> 0.94.2-1
- Updating gem versions (admiller@redhat.com)

* Fri Jun 01 2012 Adam Miller <admiller@redhat.com> 0.94.1-1
- Updating gem versions (admiller@redhat.com)
- bumping spec versions (admiller@redhat.com)
- Added filtering to template profiling (fotioslindiakos@gmail.com)
- Much more awesome profiling (fotioslindiakos@gmail.com)
- Don't need to rotate logfile numbers since logger will just append nicely
  (fotioslindiakos@gmail.com)
- Created template profiling script (fotioslindiakos@gmail.com)
- Updated template descriptors (fotioslindiakos@gmail.com)

* Thu May 31 2012 Adam Miller <admiller@redhat.com> 0.93.22-1
- Added experimental tag to templates (fotioslindiakos@gmail.com)

* Thu May 31 2012 Adam Miller <admiller@redhat.com> 0.93.21-1
- Fixed application template git_url (fotioslindiakos@gmail.com)

* Wed May 30 2012 Adam Miller <admiller@redhat.com> 0.93.20-1
- Updating gem versions (admiller@redhat.com)
- Moved templates into broker and updated broker.spec
  (fotioslindiakos@gmail.com)

* Tue May 29 2012 Adam Miller <admiller@redhat.com> 0.93.19-1
- Updating gem versions (admiller@redhat.com)
- Updating gem versions (admiller@redhat.com)

* Tue May 29 2012 Adam Miller <admiller@redhat.com> 0.93.18-1
- Updating gem versions (admiller@redhat.com)

* Fri May 25 2012 Dan McPherson <dmcphers@redhat.com> 0.93.17-1
- Updating gem versions (dmcphers@redhat.com)

* Fri May 25 2012 Adam Miller <admiller@redhat.com> 0.93.16-1
- Updating gem versions (admiller@redhat.com)
- better treatment - bug#817663 (rchopra@redhat.com)
- clean help message (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- fix bugs 824433 and 824040 and 824375 (rchopra@redhat.com)

* Fri May 25 2012 Dan McPherson <dmcphers@redhat.com> 0.93.15-1
- Updating gem versions (dmcphers@redhat.com)

* Thu May 24 2012 Dan McPherson <dmcphers@redhat.com> 0.93.14-1
- Updating gem versions (dmcphers@redhat.com)

* Thu May 24 2012 Adam Miller <admiller@redhat.com> 0.93.13-1
- Updating gem versions (admiller@redhat.com)

* Thu May 24 2012 Adam Miller <admiller@redhat.com> 0.93.12-1
- Updating gem versions (admiller@redhat.com)

* Thu May 24 2012 Adam Miller <admiller@redhat.com> 0.93.11-1
- Updating gem versions (admiller@redhat.com)
- changes for US2255 - authentication ticket caching (abhgupta@redhat.com)

* Thu May 24 2012 Adam Miller <admiller@redhat.com> 0.93.10-1
- Updating gem versions (admiller@redhat.com)
- the pkg build bombed due to krb ticket timeout and the gems weren't updated,
  fixing (admiller@redhat.com)

* Wed May 23 2012 Adam Miller <admiller@redhat.com> 0.93.9-1
- Updating gem versions (admiller@redhat.com)
- add basic sync with billing vendor logic (dmcphers@redhat.com)

* Wed May 23 2012 Dan McPherson <dmcphers@redhat.com> 0.93.8-1
- Updating gem versions (dmcphers@redhat.com)

* Tue May 22 2012 Dan McPherson <dmcphers@redhat.com> 0.93.7-1
- Updating gem versions (dmcphers@redhat.com)

* Tue May 22 2012 Adam Miller <admiller@redhat.com> 0.93.6-1
- Updating gem versions (admiller@redhat.com)
- add usage observer (dmcphers@redhat.com)
- move gear support for non-scalable apps (rchopra@redhat.com)
- Fix for domain update admin script when user exists but does not own any
  domains. Fix for domain info admin script when user exists but does not own
  any domains. (kraman@gmail.com)
- some performance tuning (dmcphers@redhat.com)

* Fri May 18 2012 Adam Miller <admiller@redhat.com> 0.93.5-1
- Updating gem versions (admiller@redhat.com)

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.93.4-1
- 

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.93.3-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Create db:test:prepare task so that we don't execute actual mongo_mapper rake
  task which is trying to connect to 'test' db in mongo and that will fail due
  to incorrect credentials. (rpenta@redhat.com)

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.93.2-1
- Updating gem versions (admiller@redhat.com)
- Enable usage modal code (rpenta@redhat.com)
- get tests running faster (dmcphers@redhat.com)
- Re-include all OpenShift components in rcov run. (rmillner@redhat.com)
- enable move_gear for scalable apps (rchopra@redhat.com)
- add syslog for usage (dmcphers@redhat.com)
- Bug 822186 (dmcphers@redhat.com)
- usage tracking options (dmcphers@redhat.com)
- Comment usage model (rpenta@redhat.com)
- Until we install mongo_mapper, disable usage model unittests
  (rpenta@redhat.com)
- Until we get plucky 0.4.4 rpm, temporarily disable mongo_mapper in
  broker.spec and ruby Gemfile (rpenta@redhat.com)
- Resolve conflicts during Usage branch merge (rpenta@redhat.com)
- fix build (dmcphers@redhat.com)
- Add rcov to broker and as a dependency for devenv for build & test.
  (rmillner@redhat.com)
- restore rhc-admin-move to original form : accepts only apps (no gears) and
  rejects scalable apps (rchopra@redhat.com)
- fix for bug821003 (rchopra@redhat.com)
- fix for bug#811576 (rchopra@redhat.com)
- Add usage summary for user (rpenta@redhat.com)
- Usage model changes (rpenta@redhat.com)
- nit (dmcphers@redhat.com)
- Initial version of Usage model: create/update/find/delete usage event in
  mongo 'usages' collection (rpenta@redhat.com)
- add a simple usage object (dmcphers@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.93.1-1
- Updating gem versions (admiller@redhat.com)
- bumping spec versions (admiller@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.92.5-1
- Updating gem versions (admiller@redhat.com)
- move_gear should not allow haproxy gear to be moved until the cartridge is
  fixed. rhc-admin-move should filter scalable apps and act accordingly
  (rchopra@redhat.com)

* Tue May 08 2012 Adam Miller <admiller@redhat.com> 0.92.4-1
- Updating gem versions (admiller@redhat.com)
- Bug 819739 (dmcphers@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.92.3-1
- Updating gem versions (admiller@redhat.com)
- added exception handling and logging to apptegic and nurture calls
  (lnader@redhat.com)
- minor changes to domain observer (lnader@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Bug 815554 (lnader@redhat.com)
- added domain observer class (lnader@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.92.2-1
- Updating gem versions (admiller@redhat.com)
- moving fix gear-uids to maintenance/bin area (rchopra@redhat.com)
- fix gears that do not have their uids set - bug# 815406 (rchopra@redhat.com)
- Fix for Bugz # 818255 (kraman@gmail.com)
- Add response status to profiler info output. (rmillner@redhat.com)
- Revert "Updating gem versions". Gem version already up to date.
  (kraman@gmail.com)
- Updating gem versions (kraman@gmail.com)
- update gem versions (dmcphers@redhat.com)
- fix for bug#816462 (rchopra@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.92.1-1
- Updating gem versions (admiller@redhat.com)
- bumping spec versions (admiller@redhat.com)

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 0.91.17-1
- 

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 0.91.16-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Found bug in profiler code when theres an exception from legacy controller.
  (rmillner@redhat.com)

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 0.91.15-1
- Updating gem versions (admiller@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix for bug# 815609 (rpenta@redhat.com)

* Tue Apr 24 2012 Dan McPherson <dmcphers@redhat.com> 0.91.14-1
- fix logic for updating gem versions (dmcphers@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 0.91.13-1
- Updating gem versions (admiller@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 0.91.12-1
- Updating gem versions (admiller@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.91.11-1
- Updating gem versions (admiller@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.91.10-1
- Updating gem versions (admiller@redhat.com)
- BugzID 814007. Added protect_from_forgery (kraman@gmail.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.91.9-1
- Updating gem versions (admiller@redhat.com)
- Remove references to rhc-admin-user-vip. (rmillner@redhat.com)
- rhc-admin-ctl-user provides the same ability. (rmillner@redhat.com)
- move crankcase mongo datastore (dmcphers@redhat.com)
- Temporary commit to build (dmcphers@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 0.91.8-1
- Updating gem versions (dmcphers@redhat.com)
- Updating gem versions (dmcphers@redhat.com)
- Add profiler to test rails configuration. (rmillner@redhat.com)
- Also scrub out http auth header from REST calls. (rmillner@redhat.com)
- Clean up the info output.  Gzip the output files since they are huge.
  (rmillner@redhat.com)
- We only have perms to write into /tmp.  Still had a reference to outfile.
  (rmillner@redhat.com)
- Add info file with request and timestamp information. (rmillner@redhat.com)

* Wed Apr 18 2012 Dan McPherson <dmcphers@redhat.com> 0.91.7-1
- fixing controller Gemfile.lock in build/release (admiller@redhat.com)

* Wed Apr 18 2012 Adam Miller <admiller@redhat.com> 0.91.6-1
- 1) removing cucumber gem dependency from express broker. 2) moved ruby
  related cucumber tests back into express. 3) fixed issue with broker
  Gemfile.lock file where ruby-prof was not specified in the dependency
  section. 4) copying cucumber features into li-test/tests automatically within
  the devenv script. 5) fixing ctl status script that used ps to list running
  processes to specify the user. 6) fixed tidy.sh script to not display error
  on fedora stickshift. (abhgupta@redhat.com)
- rhc-admin-ctl-user: added ability to set vip status (twiest@redhat.com)
- rhc-admin-ctl-user: updated to be able to set consumed gears as well.
  (twiest@redhat.com)
- typos (rmillner@redhat.com)
- Clean up some of the help text. (rmillner@redhat.com)
- Had to move profiler to ActionController::Base (rmillner@redhat.com)
- Add range to runtime squash (rmillner@redhat.com)
- Add measurement type to file name. (rmillner@redhat.com)
- Add measurement type and description in config (rmillner@redhat.com)
- It seems like most of our threads come in during processing.  Delete them
  after the fact from the report. (rmillner@redhat.com)
- Just print the thread IDs (rmillner@redhat.com)
- Add log for thread handling.  Fix config entry. (rmillner@redhat.com)
- Dont pack nils into the exclude_threads array. (rmillner@redhat.com)
- Clean up methods. Add thread squash. Pass whole cfg to printer.
  (rmillner@redhat.com)
- Profiler moved into the app controller. (rmillner@redhat.com)
- Move profiling into the controller filter. (rmillner@redhat.com)
- Used the wrong variable (rmillner@redhat.com)
- Variable was being defined lower in the code. (rmillner@redhat.com)
- Use double quotes for var expansion (rmillner@redhat.com)
- Catch nomethod in case theres no profiler config. (rmillner@redhat.com)
- Add debug logging to the profiler calls (rmillner@redhat.com)
- Add an instance of the profiler to the broker startup (rmillner@redhat.com)
- The rubygem(foo) dependency is missing from ruby-prof. (rmillner@redhat.com)
- changed configuration block for profiler. (rmillner@redhat.com)
- Add observer for profiling of specific events. (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- admin chk script to check mismatch between consumed_gears and actual gears
  for each user (rchopra@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.5-1
- release bump for mongo (mmcgrath@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.4-1
- test commit (mmcgrath@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.3-1
- gemfile bumps (mmcgrath@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.2-1
- Updating gem versions (mmcgrath@redhat.com)
- release bump for tag uniqueness (mmcgrath@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.21-1
- Updating gem versions (mmcgrath@redhat.com)
- added additional required rubygems (mmcgrath@redhat.com)
- added rubygem-term-ansicolor dep (mmcgrath@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.90.20-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- test commit (mmcgrath@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.90.19-1
- fixing gemfile.lock (mmcgrath@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.90.18-1
- Updating gem versions (admiller@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.17-1
- Updating gem versions (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.16-1
- removed test commits (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.15-1
- Test commit (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.14-1
- 

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.13-1
- test commits (mmcgrath@redhat.com)

* Tue Apr 10 2012 Adam Miller <admiller@redhat.com> 0.90.12-1
- Updating gem versions (admiller@redhat.com)

* Tue Apr 10 2012 Adam Miller <admiller@redhat.com> 0.90.11-1
- Updating gem versions (admiller@redhat.com)
- Updating gem versions (admiller@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.10-1
- updating gemfile.lock (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.9-1
- Updating gem versions (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.8-1
- Updating gem versions (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.7-1
- Updating gem versions (mmcgrath@redhat.com)

* Mon Apr 09 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.6-1
- Updating gem versions (mmcgrath@redhat.com)
- Updating gem versions (kraman@gmail.com)

* Mon Apr 09 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.5-1
- Updating gem versions (mmcgrath@redhat.com)
- cleaning up location of datatstore configuration (kraman@gmail.com)
- Updating gemfile.lock (kraman@gmail.com)
- Merge remote-tracking branch 'origin/master' into dev/kraman/US2048
  (kraman@gmail.com)
- Bunping gem version in Gemfile.lock Fix rename issue in application container
  proxy (kraman@gmail.com)
- moving bulk of the cucumber tests under stickshift and making changes so that
  tests can be run both on devenv with express  as well as with opensource
  pieces on the fedora image (abhgupta@redhat.com)
- Merge remote-tracking branch 'origin/master' (kraman@gmail.com)
- Merge remote-tracking branch 'origin/master' (kraman@gmail.com)
- Bug fixes after initial merge of OSS packages (kraman@gmail.com)
- Automatic commit of package [rhc-broker] release [0.90.2-1].
  (kraman@gmail.com)
- Updating dependencies to match new package names (kraman@gmail.com)
- Merge remote-tracking branch 'origin/dev/kraman/US2048' (kraman@gmail.com)
- Adding m-collective and oddjob gearchanger plugins (kraman@gmail.com)
- Added mongo and streamline swingshift plugins (kraman@gmail.com)
- Creating dynect plugin (kraman@gmail.com)

* Wed Apr 04 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.4-1
- Updating gem versions (mmcgrath@redhat.com)

* Wed Apr 04 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.3-1
- test commit (mmcgrath@redhat.com)

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.2-1
- Updating gem versions (mmcgrath@redhat.com)
- custom request does not take multiple nodes very well, fix for bug#806375
  (rchopra@redhat.com)
- added rhc-admin-ctl-user (twiest@redhat.com)

* Mon Apr 02 2012 Krishna Raman <kraman@gmail.com> 0.90.2-1
- Updating dependencies to match new package names (kraman@gmail.com)
- Merge remote-tracking branch 'origin/dev/kraman/US2048' (kraman@gmail.com)
- added rhc-admin-ctl-user (twiest@redhat.com)
- Adding m-collective and oddjob gearchanger plugins (kraman@gmail.com)
- Added mongo and streamline swingshift plugins (kraman@gmail.com)
- Creating dynect plugin (kraman@gmail.com)

* Sat Mar 31 2012 Dan McPherson <dmcphers@redhat.com> 0.90.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)

* Fri Mar 30 2012 Dan McPherson <dmcphers@redhat.com> 0.89.8-1
- Bug 807568 (dmcphers@redhat.com)

* Thu Mar 29 2012 Dan McPherson <dmcphers@redhat.com> 0.89.7-1
- Updating gem versions (dmcphers@redhat.com)

* Wed Mar 28 2012 Dan McPherson <dmcphers@redhat.com> 0.89.6-1
- Updating gem versions (dmcphers@redhat.com)

* Wed Mar 28 2012 Dan McPherson <dmcphers@redhat.com> 0.89.5-1
- Updating gem versions (dmcphers@redhat.com)
- cosmetics in debug statement; fix for broken cartridge configure not getting
  a deconfigure but two destroys instead (rchopra@redhat.com)
- Bug 807654 (dmcphers@redhat.com)

* Tue Mar 27 2012 Dan McPherson <dmcphers@redhat.com> 0.89.4-1
- Updating gem versions (dmcphers@redhat.com)
- fixed refs to user.namespace (lnader@redhat.com)
- change default max gears to 3 (dmcphers@redhat.com)
- BugzID 806298 (kraman@gmail.com)

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.3-1
- Updating gem versions (dmcphers@redhat.com)

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.2-1
- Updating gem versions (dmcphers@redhat.com)
- 806473 (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- parallelize mcollective calls for parallel jobs (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Merge branch 'compass', removed conflicting JS file (ccoleman@redhat.com)
- Broker and site in devenv should use RackBaseURI and be relative to content
  Remove broker/site app_scope (ccoleman@redhat.com)
- merged conflicts with master (lnader@redhat.com)
- group mcollective calls (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- US1876 (lnader@redhat.com)
- Fix for bug# 804029 (rpenta@redhat.com)
- Update stickshift gemfiles to new rack versions, remove multimap which is no
  longer required by rack (versions before .7 had a dependency, it has since
  been inlined) (ccoleman@redhat.com)
- Merge branch 'rack' (ccoleman@redhat.com)
- code cleanup checkpoint for US2091. scalable apps may not work right now.
  (rchopra@redhat.com)
- Update rack dependencies (ccoleman@redhat.com)
- Update rack to 1.3 (ccoleman@redhat.com)
- keep around OPENSHIFT_APP_DNS (dmcphers@redhat.com)

* Sat Mar 17 2012 Dan McPherson <dmcphers@redhat.com> 0.89.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)

* Thu Mar 15 2012 Dan McPherson <dmcphers@redhat.com> 0.88.8-1
- Updating gem versions (dmcphers@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.7-1
- Updating gem versions (dmcphers@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.6-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix for bug# 800095 (rpenta@redhat.com)

* Tue Mar 13 2012 Dan McPherson <dmcphers@redhat.com> 0.88.5-1
- Updating gem versions (dmcphers@redhat.com)
- make sure remove httpd proxy gets run on move failure (dmcphers@redhat.com)
- move error handling messaging (dmcphers@redhat.com)
- give a better retry success message on move (dmcphers@redhat.com)

* Mon Mar 12 2012 Dan McPherson <dmcphers@redhat.com> 0.88.4-1
- Updating gem versions (dmcphers@redhat.com)
- merging admin scripts to add/remove template into a single control script
  (abhgupta@redhat.com)
- fix for case when server_identity changes; switch to flip mcollective
  optimizations on/off (rchopra@redhat.com)
- spec file fix so that rhc-admin-chk is available in bin (rchopra@redhat.com)

* Sat Mar 10 2012 Dan McPherson <dmcphers@redhat.com> 0.88.3-1
- Updating gem versions (dmcphers@redhat.com)
- rhc-admin-chk (rchopra@redhat.com)
- checkpoint - rhc-admin-chk script - incomplete (rchopra@redhat.com)
- Fixing a couple of missed Cloud::Sdk references (kraman@gmail.com)

* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.88.2-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- Updating gem versions (dmcphers@redhat.com)
- finally ...iv/token working (rchopra@redhat.com)
- Fix factor code to read node config properly Fix rhc-admin-add-template to
  store yaml for descriptor (kraman@gmail.com)
- Making access to mongo config info consistent across broker and controller
  (kraman@gmail.com)
- Updating tests (kraman@gmail.com)
- Updates for getting devenv running (kraman@gmail.com)
- Changes to MongoDatastore: - Enabled creation of new mongodb instances with
  different config parameters. - Re-organized mongo rails configuration
  (rpenta@redhat.com)
- Renaming Cloud-SDK -> StickShift (kraman@gmail.com)
- missed a help message on the new gear sizes (rmillner@redhat.com)
- Add new env var *_USER_APP_NAME (need to rename this once the *_APP_NAME is
  switched over to *_GEAR_NAME). (ramr@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- checkpoint 3 - mcollective parallelized calls working - not integrated yet
  (rchopra@redhat.com)
- Increase timeouts to 60 secs. (ramr@redhat.com)
- Broker defaults to small gear size (rmillner@redhat.com)
- Fixed rhc-admin-add-template to properly parse YAML and JSON files
  (fotios@redhat.com)
- checkpoint 2 - parallel execution over mcollective - not integrated yet
  (rchopra@redhat.com)
- checkpoint - half the setup for parallel mcollective calls - not integrated
  (rchopra@redhat.com)
- fix issue with move changing nodes half way through (dmcphers@redhat.com)
- fix a couple comments (dmcphers@redhat.com)
- remove double URL encoding (lnader@redhat.com)

* Fri Mar 02 2012 Dan McPherson <dmcphers@redhat.com> 0.88.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- fail if you dont get a result from rpc_exec (dmcphers@redhat.com)
- make help pages fast on admin tools and sync output from migrate
  (dmcphers@redhat.com)
- rolling back changes for raising exceptions when component is not found on
  gear (rchopra@redhat.com)
- do not consider deconfigure benign if a component is not found on the node
  (rchopra@redhat.com)

* Thu Mar 01 2012 Dan McPherson <dmcphers@redhat.com> 0.87.11-1
- Adding admin script to set user VIP status (kraman@gmail.com)

* Wed Feb 29 2012 Dan McPherson <dmcphers@redhat.com> 0.87.10-1
- Updating gem versions (dmcphers@redhat.com)

* Tue Feb 28 2012 Dan McPherson <dmcphers@redhat.com> 0.87.9-1
- Updating gem versions (dmcphers@redhat.com)
- Fix for Bugz 798256 Consolidating user lookup (kraman@gmail.com)
- dont pre/post move for same uid (dmcphers@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.8-1
- Updating gem versions (dmcphers@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.7-1
- 

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.6-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- gear info REST api call fix (rpenta@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.5-1
- Updating gem versions (dmcphers@redhat.com)
- BugzID# 797098, 796088. Application validation (kraman@gmail.com)
- Adding config for template collection to all environments (kraman@gmail.com)
- Bigfix. App creation was failing for non vip users. (kraman@gmail.com)
- US1908: Allow only vip users to create gears that are larger than medium
  (std) (kraman@gmail.com)

* Sat Feb 25 2012 Dan McPherson <dmcphers@redhat.com> 0.87.4-1
- Updating gem versions (dmcphers@redhat.com)
- get rid of debug log messages in libra_check (lnader@redhat.com)
- adding back Gemfile.lock assuming it was deleted by accident
  (dmcphers@redhat.com)
- Temporary commit to build (ffranz@redhat.com)
- Update cartridge configure hooks to load git repo from remote URL Add REST
  API to create application from template Moved application template
  models/controller to cloud-sdk (kraman@gmail.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- bind dns service bug fixes and cleanup (rpenta@redhat.com)
- fix validate args for mcollective calls as we are sending json strings over
  now (rchopra@redhat.com)
- jsonify connector output from multiple gears for consumption by subscriber
  connectors (rchopra@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.87.3-1
- Updating gem versions (dmcphers@redhat.com)
- trying to fix the build... continued (dmcphers@redhat.com)
- fixing gemfile.lock for open4/dnsruby dependencies (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- checkpoint 3 - horizontal scaling, minor fixes, connector hook for haproxy
  not complete (rchopra@redhat.com)
- Adding template management tests (kraman@gmail.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- Add show-proxy call. (rmillner@redhat.com)
- Adding admin scripts to manage templates Adding REST API for creatig
  applications given a template GUID (kraman@gmail.com)
- checkpoint 2 - option to create scalable type of app, scaleup/scaledown apis
  added, group minimum requirements get fulfilled (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- checkpoint 1 - horizontal scaling broker support (rchopra@redhat.com)
- Adding admin scripts to manage templates (kraman@gmail.com)
- Added ability to list and retrieve application template data
  (kraman@gmail.com)

* Mon Feb 20 2012 Dan McPherson <dmcphers@redhat.com> 0.87.2-1
- Updating gem versions (dmcphers@redhat.com)
- Revert "Updating gem versions" (ramr@redhat.com)
- Updating gem versions (ramr@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.87.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.86.8-1
- Updating gem versions (dmcphers@redhat.com)

* Wed Feb 15 2012 Dan McPherson <dmcphers@redhat.com> 0.86.7-1
- Updating gem versions (dmcphers@redhat.com)
- Bugzid# 789916 (kraman@gmail.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.86.6-1
- Updating gem versions (dmcphers@redhat.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.86.5-1
- Updating gem versions (dmcphers@redhat.com)
- add find_one capability (dmcphers@redhat.com)
- Supressing debug output for cartridge-list to make logs legible Turning on
  rails caching for streamline-aws configuration (kraman@gmail.com)
- try a different order with the embedded feature (dmcphers@redhat.com)
- cleaning up version reqs (dmcphers@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.4-1
- Updating gem versions (dmcphers@redhat.com)
- share common move logic (dmcphers@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Add calls to
  backend for proxy." (rmillner@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.3-1
- Updating gem versions (dmcphers@redhat.com)
- cleaning up specs to force a build (dmcphers@redhat.com)
- add back capacity and restrict remove node to 0 capacity nodes
  (dmcphers@redhat.com)

* Sat Feb 11 2012 Dan McPherson <dmcphers@redhat.com> 0.86.2-1
- Updating gem versions (dmcphers@redhat.com)
- get move working again and add quota support (dmcphers@redhat.com)
- Add calls to backend for proxy. (rmillner@redhat.com)
- Fix broker auth service, bug# 787297 (rpenta@redhat.com)
- Minor fixes to export/conceal port functions (kraman@gmail.com)
- Bug 789225 (dmcphers@redhat.com)
- bug 722828 (wdecoste@localhost.localdomain)
- bug 722828 (wdecoste@localhost.localdomain)
- more move debug + test case simplifications (dmcphers@redhat.com)
- Fixing add/remove embedded cartridges Fixing domain info on legacy broker
  controller Fixing start/stop/etc app and cart. control calls for legacy
  broker (kraman@gmail.com)
- Update application_container_proxy to be able to distnguish between
  app,framework,embedded carts and perform config/start/etc hooks appropriately
  (kraman@gmail.com)
- Bug fixes for saving connection list Abstracting difference between
  framework/embedded cart in application_container_proxy and application
  (kraman@gmail.com)
- Renamed ApplicationContainer to Gear to avoid confusion Fixed gear
  creation/configuration/deconfiguration for framework cartridge Fixed
  save/load of group insatnce map Removed hacks where app was assuming one gear
  only Started changes to enable rollback if operation fails (kraman@gmail.com)
- Fixes for re-enabling cli tools. git url is not yet working.
  (kraman@gmail.com)
- Updated code to make it re-enterant. Adding/removing dependencies does not
  change location of dependencies that did not change.
  (rchopra@unused-32-159.sjc.redhat.com)
- Updating models to improove schems of descriptor in mongo Moved
  connection_endpoint to broker (kraman@gmail.com)
- Changes to re-enable app to be saved/retrieved to/from mongo Various bug
  fixes (kraman@gmail.com)
- Creating models for descriptor Fixing manifest files Added command to list
  installed cartridges and get descriptors (kraman@gmail.com)
- Merge branch 'master' into haproxy (mmcgrath@redhat.com)
- Adding expose-port and conceal-port (mmcgrath@redhat.com)
- change status to use normal client_result instead of special handling
  (dmcphers@redhat.com)
- add force stop to move (dmcphers@redhat.com)
- better messaging on move deconfigure failure (dmcphers@redhat.com)
- add warning about existing migration data (dmcphers@redhat.com)
- restrict ctl-district to allowed commands (dmcphers@redhat.com)
- Bug 787994 (dmcphers@redhat.com)
- move server_identities to array (dmcphers@redhat.com)
- make actions and cdk commands match (dmcphers@redhat.com)
- increase std and large gear restrictions (dmcphers@redhat.com)
- add app url lookup to move (dmcphers@redhat.com)
- always take the destination district uuid (dmcphers@redhat.com)
- keep apps stopped or idled on move (dmcphers@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.86.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- add move by uuid (dmcphers@redhat.com)
- Bug 786709 (dmcphers@redhat.com)
- fix comment (dmcphers@redhat.com)
- double url encode rhlogin for apptegic (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Removing specific version dependency for rest-client from gemfile
  (kraman@gmail.com)
- Removing specific version dependency for rest-client from gemfile
  (kraman@gmail.com)
- made changes to dns_service.rb so it can be imported and used outside rails
  (lnader@dhcp-240-165.mad.redhat.com)
