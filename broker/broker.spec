%define htmldir %{_localstatedir}/www/html
%define brokerdir %{_localstatedir}/www/libra/broker

Summary:   Li broker components
Name:      rhc-broker
Version:   0.86.2
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
Requires:  rubygem-cloud-sdk-controller
Requires:  rubygem-bson_ext
Requires:  rubygem-rest-client
Requires:  rubygem-thread-dump

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
cp -r . %{buildroot}%{brokerdir}
ln -s %{brokerdir}/public %{buildroot}%{htmldir}/broker

mkdir -p %{buildroot}%{brokerdir}/run
mkdir -p %{buildroot}%{brokerdir}/log
touch %{buildroot}%{brokerdir}/log/production.log
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-domain %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-app %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-cartridge-do %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-move %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-district %{buildroot}/%{_bindir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,-,-) %{brokerdir}/log/production.log
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
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-app
%attr(0750,-,-) %{_bindir}/rhc-admin-cartridge-do
%attr(0750,-,-) %{_bindir}/rhc-admin-move
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-district

%post
/bin/touch %{brokerdir}/log/production.log

%changelog
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

* Thu Feb 02 2012 Dan McPherson <dmcphers@redhat.com> 0.85.29-1
- Bug 786687 (dmcphers@redhat.com)
- Moved back rest-client version from 1.6.7 to 1.6.1 Added rubygem-rest-client
  as a dependency for express broker (kraman@gmail.com)

* Thu Feb 02 2012 Dan McPherson <dmcphers@redhat.com> 0.85.28-1
- Updating gem versions (dmcphers@redhat.com)
- Bug fixes for AuthService running in integrated mode (BZ 786330)
  (aboone@redhat.com)

* Wed Feb 01 2012 Dan McPherson <dmcphers@redhat.com> 0.85.27-1
- fix selinux issues with move (dmcphers@redhat.com)

* Tue Jan 31 2012 Dan McPherson <dmcphers@redhat.com> 0.85.26-1
- Updating gem versions (dmcphers@redhat.com)
- Mongo connection recovery code for Express/mongo_data_store.rb
  (rpenta@redhat.com)
- - Handle both ReplicaSet and normal mongodb connection - Retry for 30 secs
  (60 times in 0.5 sec frequency) in case of mongo connection failure. - On
  devenv, configure/start mongod with replicaSet = 1 (rpenta@redhat.com)
- added more debugging statements (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- added more debugging statements (lnader@dhcp-240-165.mad.redhat.com)
- better logging (dmcphers@redhat.com)
- add small sleep after stop on move (dmcphers@redhat.com)
- additional test + use new record instead of persisted (dmcphers@redhat.com)
- various messaging improvements (dmcphers@redhat.com)

* Mon Jan 30 2012 Dan McPherson <dmcphers@redhat.com> 0.85.25-1
- Updating gem versions (dmcphers@redhat.com)
- update json version (dmcphers@redhat.com)

* Mon Jan 30 2012 Dan McPherson <dmcphers@redhat.com> 0.85.24-1
- update treetop refs (dmcphers@redhat.com)

* Mon Jan 30 2012 Dan McPherson <dmcphers@redhat.com> 0.85.23-1
- Updating gem versions (dmcphers@redhat.com)
- add name and node profile to districts (dmcphers@redhat.com)
- move cleanup (dmcphers@redhat.com)
- fix move (dmcphers@redhat.com)
- Revert changes to development.log in site,broker,devenv spec
  (aboone@redhat.com)

* Sun Jan 29 2012 Dan McPherson <dmcphers@redhat.com> 0.85.22-1
- 

* Sun Jan 29 2012 Dan McPherson <dmcphers@redhat.com> 0.85.21-1
- Updating gem versions (dmcphers@redhat.com)
- Bug 785550 and 785514 (dmcphers@redhat.com)
- make mongo queryable (dmcphers@redhat.com)
- change rhlogin to login for sdk (dmcphers@redhat.com)
- moving rhc-admin-create-district logic to rhc-admin-ctl-district and add more
  tests (dmcphers@redhat.com)
- Temporary commit to build (dmcphers@redhat.com)
- add base cloud-sdk broker (dmcphers@redhat.com)

* Sat Jan 28 2012 Dan McPherson <dmcphers@redhat.com> 0.85.20-1
- Updating gem versions (dmcphers@redhat.com)
- mongo performance changes and mongo unit tests (dmcphers@redhat.com)
- mongo ds terminology improvements and get basic broker controller tests
  running again (dmcphers@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.85.19-1
- Updating gem versions (dmcphers@redhat.com)
- migration changes (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- US1741 (lnader@dhcp-240-165.mad.redhat.com)
- add bson_ext (dmcphers@redhat.com)
- dont go quite as far with the attr tracking (dmcphers@redhat.com)
- Bug 692401 (dmcphers@redhat.com)
- handle already reserved uids (dmcphers@redhat.com)
- Another fix for build issue created in 532e0e8 (aboone@redhat.com)
- Fix for 532e0e8, also properly set permissions on logs (aboone@redhat.com)
- Since site is touching the development.log during build, remove touches from
  devenv.spec (aboone@redhat.com)
- deploy httpd proxy from migration (dmcphers@redhat.com)
- rename li-controller to cloud-sdk-node (dmcphers@redhat.com)
- config cleanup for ticket (dmcphers@redhat.com)
- Add and remove capacity from a district (dmcphers@redhat.com)
- cleanup apis (dmcphers@redhat.com)
- district fixes (dmcphers@redhat.com)
- restrict app create to within districts within prod (dmcphers@redhat.com)
- allow install from source plus some districts changes (dmcphers@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.18-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- resolve merge conflicts (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Resolve merge conflicts (rpenta@redhat.com)
- Resolve merge conflicts (rpenta@redhat.com)
- ssh keys code refactor (rpenta@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.17-1
- Updating gem versions (dmcphers@redhat.com)
- fix test case (dmcphers@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.16-1
- Updating gem versions (dmcphers@redhat.com)
- fix test cases (dmcphers@redhat.com)
- make move district aware (dmcphers@redhat.com)
- move gear limit checking to mongo (dmcphers@redhat.com)
- Bug 784130 (dmcphers@redhat.com)
- improve mongo usage (dmcphers@redhat.com)
- lots of district error handling (dmcphers@redhat.com)

* Fri Jan 20 2012 Dan McPherson <dmcphers@redhat.com> 0.85.15-1
- Updating gem versions (dmcphers@redhat.com)
- build fixes (dmcphers@redhat.com)
- fix build (dmcphers@redhat.com)

* Fri Jan 20 2012 Dan McPherson <dmcphers@redhat.com> 0.85.14-1
- Updating gem versions (dmcphers@redhat.com)
- getting to the real districts mongo impl (dmcphers@redhat.com)

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.13-1
- Updating gem versions (mmcgrath@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.12-1
- 

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.11-1
- Updating gem versions (dmcphers@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.10-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Merge remote branch 'origin/REST' (lnader@dhcp-240-165.mad.redhat.com)
- Merge remote branch 'origin/master' into REST
  (lnader@dhcp-240-165.mad.redhat.com)
- Added new method to auth service with support for user/pass based
  authentication for new REST API (kraman@gmail.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.9-1
- Updating gem versions (dmcphers@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.8-1
- Updating gem versions (dmcphers@redhat.com)
- district work (dmcphers@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.7-1
- Updating gem versions (dmcphers@redhat.com)
- fix build (dmcphers@redhat.com)

* Wed Jan 18 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.6-1
- Updating gem versions (mmcgrath@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- mongo datastore fixes (rpenta@redhat.com)
- use two different collections (dmcphers@redhat.com)
- add broker mongo extensions (dmcphers@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.85.5-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- handle app being removed during migration (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- configure/start mongod service for new devenv launch (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge/resolve conflicts from master (rpenta@redhat.com)
- s3-to-mongo: code cleanup (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- fixes related to mongo datastore (rpenta@redhat.com)
- merge changes from master (rpenta@redhat.com)
- s3-to-mongo: bug fixes (rpenta@redhat.com)
- Merge changes from master (rpenta@redhat.com)
- Added MongoDataStore model (rpenta@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.4-1
- remove broker gem refs for threaddump (bdecoste@gmail.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.3-1
- US1667: threaddump for rack (wdecoste@localhost.localdomain)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (wdecoste@localhost.localdomain)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (wdecoste@localhost.localdomain)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (wdecoste@localhost.localdomain)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (wdecoste@localhost.localdomain)
- Temporary commit to build (wdecoste@localhost.localdomain)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- Updating gem versions (dmcphers@redhat.com)
- districts (work in progress) (dmcphers@redhat.com)
- fix get all users with app named user.json (dmcphers@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- Bug 781254 (dmcphers@redhat.com)
