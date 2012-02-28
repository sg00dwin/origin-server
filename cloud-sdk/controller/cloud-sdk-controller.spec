%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname cloud-sdk-controller
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        Cloud Development Controller
Name:           rubygem-%{gemname}
Version:        0.5.6
Release:        1%{?dist}
Group:          Development/Languages
License:        ASL 2.0
URL:            http://openshift.redhat.com
Source0:        rubygem-%{gemname}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(activemodel)
Requires:       rubygem(highline)
Requires:       rubygem(json_pure)
Requires:       rubygem(mocha)
Requires:       rubygem(parseconfig)
Requires:       rubygem(state_machine)
Requires:       rubygem(dnsruby)
Requires:       rubygem(cloud-sdk-common)
Requires:       rubygem(open4)

BuildRequires:  ruby
BuildRequires:  rubygems
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %version

%package -n ruby-%{gemname}
Summary:        Cloud Development Controller Library
Requires:       rubygem(%{gemname}) = %version
Provides:       ruby(%{gemname}) = %version

%description
This contains the Cloud Development Controller packaged as a rubygem.

%description -n ruby-%{gemname}
This contains the Cloud Development Controller packaged as a ruby site library.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
mkdir -p %{buildroot}%{ruby_sitelib}

# Build and install into the rubygem structure
gem build %{gemname}.gemspec
gem install --local --install-dir %{buildroot}%{gemdir} --force %{gemname}-%{version}.gem

# Symlink into the ruby site library directories
ln -s %{geminstdir}/lib/%{gemname} %{buildroot}%{ruby_sitelib}
ln -s %{geminstdir}/lib/%{gemname}.rb %{buildroot}%{ruby_sitelib}

%clean
rm -rf %{buildroot}                                

%files
%defattr(-,root,root,-)
%dir %{geminstdir}
%doc %{geminstdir}/Gemfile
%{gemdir}/doc/%{gemname}-%{version}
%{gemdir}/gems/%{gemname}-%{version}
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

%files -n ruby-%{gemname}
%{ruby_sitelib}/%{gemname}
%{ruby_sitelib}/%{gemname}.rb

%changelog
* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.5.6-1
- Updating gem versions (dmcphers@redhat.com)
- BugzID# 797098, 796088. Application validation (kraman@gmail.com)
- BugzID# 797782. Adding links for application templates (kraman@gmail.com)
- BugzID 797764. Skip deconfigure_dependencies if app descriptor elaboration
  failed. Return error message if invalid cartridge was specified in template
  and revert app creation (kraman@gmail.com)

* Sat Feb 25 2012 Dan McPherson <dmcphers@redhat.com> 0.5.5-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix gear controller (rpenta@redhat.com)
- Added rest call to get gear info of all the applications (rpenta@redhat.com)
- add ssh keys to newly scaled up gear (rchopra@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Bug 797270 - [REST API] Create of key not returning (lnader@redhat.com)
- gears get node profiles. service dependency is taken care of in exec order
  (rchopra@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- bug fix for bind dns service (rpenta@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- restore ssh key mechanism, and execute connections outside of configure
  dependencies (rchopra@redhat.com)
- Bug 796363 (lnader@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- renaming jbossas7 (dmcphers@redhat.com)
- For scalable apps, app-uuid should be haproxy's gear-uuid
  (rchopra@redhat.com)
- node profile added for web cart gears (rchopra@redhat.com)
- fix scaledown (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- re-organize putting of ssh keys in gears (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- This block of code should only be called on a scalable app.
  (rmillner@redhat.com)
- reorder configure and expose port check (rchopra@redhat.com)
- fix php publish url to send exposed port (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- add ssh keys before connectors are called on create. expose port for
  web_carts. (rchopra@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Cloud Sdk app container proxy changes: Added new methods that matches the
  interface used by express proxy container (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- bug fix 796287 and US1895 (lnader@redhat.com)
- bug fix 796287 and US1895 (lnader@redhat.com)
- check group instance's reused_by to find if web_cart belongs there
  (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (abhgupta@redhat.com)
- fixing method signature - incorrect number of args (abhgupta@redhat.com)
- create dns entry before calling connectors (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- dns should be deconfigured before app is deleted (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- added exit_codes to messages generated by rest API in addition to ones passed
  from validators and models (lnader@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- bug fixes and update to cucumber tests (lnader@redhat.com)
- register dns name for scalable gears at creation time; rest api to scale
  (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (abhgupta@redhat.com)
- initial implementations for a bunch of methods in application container proxy
  for cloud sdk controller (abhgupta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Bug 796363 (lnader@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- shellescape connector data exchange (rchopra@redhat.com)
- BugzID 795829 (kraman@gmail.com)
- BugzId# 795829: find_by_uuid no longer requires login name when looking up
  application (kraman@gmail.com)
- Update cartridge configure hooks to load git repo from remote URL Add REST
  API to create application from template Moved application template
  models/controller to cloud-sdk (kraman@gmail.com)
- cloud sdk app destroy (bypass mcollective) (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- bind dns service bug fixes and cleanup (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- bug fixes (lnader@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- fix validate args for mcollective calls as we are sending json strings over
  now (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (abhgupta@redhat.com)
- more method implementations (abhgupta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- jsonify connector output from multiple gears for consumption by subscriber
  connectors (rchopra@redhat.com)
- minor bug fix (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- minor changes to a few method signatures (abhgupta@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- REST call to create a scalable app; fix in cdk-connector-execute; fix in
  app.scaleup function (rchopra@redhat.com)
- changes to enable app creation for opensource cloud sdk (abhgupta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- cloud-sdk application container proxy changes (rpenta@redhat.com)
- User Story US1895: REST API error message updates (lnader@redhat.com)
- validator renamed (lnader@redhat.com)
- renamed namespace_validator to domain_validator (lnader@redhat.com)
- add validators and improvements to REST API validation errors
  (lnader@redhat.com)
- corrected typo :code versus :exit_code (lnader@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.5.4-1
- Updating gem versions (dmcphers@redhat.com)
- dont need targz of ddns test capsule (mlamouri@redhat.com)
- syntax bug fix (rchopra@redhat.com)
- checkpoint 4 - horizontal scaling bug fixes, multiple gears ok, scaling to be
  tested (rchopra@redhat.com)
- typo fix (rchopra@redhat.com)
- add bind_dns_service to cloud-sdk-controller.rb (rpenta@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- checkpoint 3 - horizontal scaling, minor fixes, connector hook for haproxy
  not complete (rchopra@redhat.com)
- merging changes (abhgupta@redhat.com)
- Added application creation from template test case (kraman@gmail.com)
- initial checkin for US1900 (abhgupta@redhat.com)
- Merge remote-tracking branch 'origin/master' (mlamouri@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- typo fixes (rchopra@redhat.com)
- Add show-proxy call. (rmillner@redhat.com)
- added BindDnsService unit test and test service module (mlamouri@redhat.com)
- merged BindDnsService and packaging update (mlamouri@redhat.com)
- Adding admin scripts to manage templates Adding REST API for creatig
  applications given a template GUID (kraman@gmail.com)
- checkpoint 2 - option to create scalable type of app, scaleup/scaledown apis
  added, group minimum requirements get fulfilled (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- checkpoint 1 - horizontal scaling broker support (rchopra@redhat.com)

* Mon Feb 20 2012 Dan McPherson <dmcphers@redhat.com> 0.5.3-1
- Updating gem versions (dmcphers@redhat.com)
- secure jenkins (dmcphers@redhat.com)
- Revert "Updating gem versions" (ramr@redhat.com)
- Sigh -- friday night build failures -- switching version by hand to 0.5.1 to
  get build running. Do need something strong now ... (ramr@redhat.com)

* Fri Feb 17 2012 Ram Ranganathan <ramr@redhat.com> 0.5.1-1
- Updating gem versions (ramr@redhat.com)
- bug fixes 789785 and 794917 (lnader@redhat.com)
- BugzID# 794664. Add alias not returns an error if using an alias that already
  used on a different app. (kraman@gmail.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.5.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- mongo save should not happen 5 times for an application create - fixed to 2
  times (rchopra@redhat.com)
- Fixing rails route to pick up base path from configuration instead of being
  hardcoded. (kraman@gmail.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.4.8-1
- Updating gem versions (dmcphers@redhat.com)
- BugzID# 790637. (kraman@gmail.com)

* Wed Feb 15 2012 Dan McPherson <dmcphers@redhat.com> 0.4.7-1
- Updating gem versions (dmcphers@redhat.com)
- bug 790635 (wdecoste@localhost.localdomain)
- fix for bug#790672 (rchopra@redhat.com)
- BugzId #790637. Fixed broker code. Legacy rhc tools now ask user to add a new
  key. (kraman@gmail.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.4.6-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- bug 790370 (lnader@redhat.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.4.5-1
- Updating gem versions (dmcphers@redhat.com)
- add find_one capability (dmcphers@redhat.com)
- cleaning up version reqs (dmcphers@redhat.com)
- Bug fixes:   - Fix deconfigure order   - Fix type in exception handler of app
  configure (kraman@gmail.com)
- typo fix (rchopra@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.4.4-1
- Updating gem versions (dmcphers@redhat.com)
- Bugfix for bugz#789891. Fixed issue where cartridge was left as a dependency
  in the descriptor even if configure failed (kraman@gmail.com)
- Fix for bugz# 789814. Fixed 10gen-mms-agent and rockmongo descriptors. Fixed
  info sent back by legacy broker when cartridge doesnt not have info for
  embedded cart. (kraman@gmail.com)
- Fix for Bugz#790153. Legacy broker was throwing an error when user did not
  have ssh key (Domain created with new REST API without ssh key)
  (kraman@gmail.com)
- Adding REST link for descriptor (kraman@gmail.com)
- Bugfixes in postgres cartridge descriptor Bugfix in connection resolution
  inside profile Adding REST API to retrieve descriptor (kraman@gmail.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.4.3-1
- Updating gem versions (dmcphers@redhat.com)
- cleaning up specs to force a build (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- merging kraman (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Fixing some expose/conceal bits (mmcgrath@redhat.com)

* Sat Feb 11 2012 Dan McPherson <dmcphers@redhat.com> 0.4.2-1
- Updating gem versions (dmcphers@redhat.com)
- cleanup specs (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- fix for finding out whether a component is auto-generated or not
  (rchopra@redhat.com)
- Fixed typo (kraman@gmail.com)
- Provide a way for admin-move script to update embeddec cart information
  (kraman@gmail.com)
- Changing server_id to server_identity to be consistent with rest of code
  (kraman@gmail.com)
- change component/group paths in descriptor (rchopra@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix broker auth service, bug# 787297 (rpenta@redhat.com)
- bug fixes and refactoring (lnader@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Minor fixes to export/conceal port functions (kraman@gmail.com)
- Bug 789179 (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- bug fixes and improvements in REST API (lnader@redhat.com)
- calling private functions without self qualifier (rchopra@redhat.com)
- fixing merge (mmcgrath@redhat.com)
- Fixes to throw exceptions on failures. Fixes to stop app if start fails and
  other recovery processes. (kraman@gmail.com)
- fixing alias add/remove (rchopra@redhat.com)
- Temporary commit to build (mmcgrath@redhat.com)
- merging (mmcgrath@redhat.com)
- Added expose and conceal port (mmcgrath@redhat.com)
- Fixed env var delete on node Added logic to save app after critical steps on
  node suring create/destroy/configure/deconfigure Handle failures on
  start/stop of application or cartridge (kraman@gmail.com)
- bug 722828 (bdecoste@gmail.com)
- bug 722828 (wdecoste@localhost.localdomain)
- bug 722828 (wdecoste@localhost.localdomain)
- What!!! List of cartridges is hardcoded in code ... try something like:   ls
  /usr/libexec/li/cartridges/ |  grep -Ev 'abstract|abstract-httpd|embedded'
  its a lil' better!! :^) (ramr@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- moved links from app to cartridge (lnader@redhat.com)
- correcting haproxy name (mmcgrath@redhat.com)
- Fix HAProxy descriptor Add HAProxy to standalone cart list on
  CartridgeCache(temp till descriptor changes are made on cloud-sdk-node)
  (kraman@gmail.com)
- Fixing add/remove embedded cartridges Fixing domain info on legacy broker
  controller Fixing start/stop/etc app and cart. control calls for legacy
  broker (kraman@gmail.com)
- cleanup function to be called after elaboration (rchopra@redhat.com)
- get the deleted components out of re-elaboration (rchopra@redhat.com)
- re-elaborate descriptor after remove dependency (rchopra@redhat.com)
- remove self from dependency of component instance (rchopra@redhat.com)
- bug fix in re-entrancy code (rchopra@redhat.com)
- add application to configure/start order (rchopra@redhat.com)
- auto generate configure/start order (rchopra@redhat.com)
- auto-merge top groups; minor improvements to re-entrancy algorithm
  (rchopra@redhat.com)
- Bug fixes for saving connection list Abstracting difference between
  framework/embedded cart in application_container_proxy and application
  (kraman@gmail.com)
- Renamed ApplicationContainer to Gear to avoid confusion Fixed gear
  creation/configuration/deconfiguration for framework cartridge Fixed
  save/load of group insatnce map Removed hacks where app was assuming one gear
  only Started changes to enable rollback if operation fails (kraman@gmail.com)
- bug fixes for app dependency manipulation (rchopra@redhat.com)
- server_identity is container's uuid (rchopra@redhat.com)
- Added backward compat code to force first application containers uuid =
  application uuid (kraman@gmail.com)
- Fixes for re-enabling cli tools. git url is not yet working.
  (kraman@gmail.com)
- code for automerging top groups - not integrated yet, to be tested. also a
  minor bug fix (rchopra@unused-32-159.sjc.redhat.com)
- Updated code to make it re-enterant. Adding/removing dependencies does not
  change location of dependencies that did not change.
  (rchopra@unused-32-159.sjc.redhat.com)
- Updating models to improove schems of descriptor in mongo Moved
  connection_endpoint to broker (kraman@gmail.com)
- Added group overrides implementation Added colocation on connections
  implementation (rchopra@redhat.com)
- Use cart.requires_feature as dependencies in each component
  (rchopra@redhat.com)
- Changes to re-enable app to be saved/retrieved to/from mongo Various bug
  fixes (kraman@gmail.com)
- Added basic elaboration of components and connections (rchopra@redhat.com)
- Creating models for descriptor Fixing manifest files Added command to list
  installed cartridges and get descriptors (kraman@gmail.com)
- bug fixes and enhancements in the rest API (lnader@redhat.com)
- simplify a lot of the internals test cases (make them faster)
  (dmcphers@redhat.com)
- Adding expose-port and conceal-port (mmcgrath@redhat.com)
- remove extra broker field (dmcphers@redhat.com)
- change state machine dep (dmcphers@redhat.com)
- move the rest of the controller tests into broker (dmcphers@redhat.com)
- stop using hard coded value (dmcphers@redhat.com)
- print correct image name in streamlined verify process (dmcphers@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.4.1-1
- Updating gem versions (dmcphers@redhat.com)
- add move by uuid (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- mongo wrapper: 'use <user-db>' instead of 'use admin' for authentication
  (rpenta@redhat.com)

