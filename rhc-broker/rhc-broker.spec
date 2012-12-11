%define htmldir %{_var}/www/html
%define brokerdir %{_var}/www/openshift/broker

Summary:   Li broker components
Name:      rhc-broker
Version: 1.2.4
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-broker-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-common
Requires:  rhc-server-common
Requires:  httpd
Requires:  mod_ssl
Requires:  mod_passenger
Requires:  ruby193
Requires:  ruby193-rubygem-json
Requires:  ruby193-rubygem-parseconfig
Requires:  rubygem-passenger-native-libs
Requires:  ruby193-rubygem-rails
Requires:  ruby193-rubygem-xml-simple
Requires:  rubygem-openshift-origin-controller
Requires:  ruby193-rubygem-bson_ext
Requires:  ruby193-rubygem-rest-client
Requires:  rubygem-openshift-origin-auth-streamline
Requires:  rubygem-openshift-origin-dns-dynect
Requires:  rubygem-openshift-origin-msg-broker-mcollective
Requires:  ruby193-rubygem-mongo_mapper
Requires:  ruby193-rubygem-wddx
Requires:  ruby193-rubygem-pony
Requires:  mcollective-qpid-plugin
# As broker admin scripts are opensourced they are placed into this package
Requires:  openshift-origin-broker-util
Provides:  openshift-origin-broker
Provides:  openshift-broker
Requires:  ruby193-rubygem-simplecov
#Requires:  ruby193-rubygem-mongoid
Requires:  ruby193-rubygem-stomp
Requires:  ruby193-rubygem-open4
Requires:  ruby193-rubygem-regin
Requires:  ruby193-rubygem-ruby-prof
Requires:  ruby193-rubygem-systemu
Requires:  ruby193-rubygem-dnsruby
Requires:  ruby193-rubygem-bigdecimal
Requires:  ruby193-rubygem-state_machine
Requires:  ruby193-rubygem-minitest

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
mkdir -p %{buildroot}/usr/lib/openshift/broker
mkdir -p %{buildroot}/etc/openshift/plugins.d/

mv application_templates %{buildroot}/usr/lib/openshift/broker
cp -r . %{buildroot}%{brokerdir}
ln -s %{brokerdir}/public %{buildroot}%{htmldir}/broker

mkdir -p %{buildroot}%{brokerdir}/run
mkdir -p %{buildroot}%{brokerdir}/log
mkdir -p %{buildroot}%{_var}/log/openshift
mkdir -p -m 770 %{buildroot}%{brokerdir}/tmp/cache
mkdir -p -m 770 %{buildroot}%{brokerdir}/tmp/pids
mkdir -p -m 770 %{buildroot}%{brokerdir}/tmp/sessions
mkdir -p -m 770 %{buildroot}%{brokerdir}/tmp/sockets

mv %{buildroot}%{brokerdir}/script/rhc-admin-cartridge-do %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-migrate %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-usage %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-plan %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-stale-dns %{buildroot}/%{_bindir}

cp conf/broker.conf %{buildroot}/etc/openshift/
cp conf/broker-dev.conf %{buildroot}/etc/openshift/
cp conf/openshift-origin-msg-broker-mcollective-dev.conf %{buildroot}/etc/openshift/plugins.d/
cp conf/openshift-origin-msg-broker-mcollective.conf %{buildroot}/etc/openshift/plugins.d/
cp conf/quickstarts.json %{buildroot}/etc/openshift/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%attr(0770,root,libra_user) %{brokerdir}/tmp
%defattr(0640,root,libra_user,0750)
%ghost %attr(0660,root,root) %{brokerdir}/log/production.log
%ghost %attr(0660,root,root) %{_var}/log/openshift/user_action.log
%config(noreplace) %{brokerdir}/config/keys/public.pem
%config(noreplace) %{brokerdir}/config/keys/private.pem
%attr(0600,-,-) %config(noreplace) %{brokerdir}/config/keys/rsync_id_rsa
%config(noreplace) %{brokerdir}/config/keys/rsync_id_rsa.pub
%attr(0750,-,-) %{brokerdir}/config/keys/generate_rsa_keys
%attr(0750,-,-) %{brokerdir}/config/keys/generate_rsync_rsa_keys
%attr(0750,-,-) %{brokerdir}/script
%{brokerdir}
%{htmldir}/broker
%attr(0750,-,-) %{_bindir}/rhc-admin-cartridge-do
%attr(0750,-,-) %{_bindir}/rhc-admin-migrate
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-usage
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-plan
%attr(0750,-,-) %{_bindir}/rhc-admin-stale-dns
/usr/lib/openshift/broker/application_templates

%config(noreplace) /etc/openshift/quickstarts.json
%config(noreplace) /etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf
%config(noreplace) /etc/openshift/broker.conf
/etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective-dev.conf
/etc/openshift/broker-dev.conf

%post
if [ ! -f %{brokerdir}/log/production.log ]; then
  /bin/touch %{brokerdir}/log/production.log
  chown root:libra_user %{brokerdir}/log/production.log
  chmod 660 %{brokerdir}/log/production.log
fi

if [ ! -f %{_localstatedir}/log/openshift/user_action.log ]; then
  /bin/touch %{_localstatedir}/log/openshift/user_action.log
  chown root:libra_user %{_localstatedir}/log/openshift/user_action.log
  chmod 660 %{_localstatedir}/log/openshift/user_action.log
fi

%changelog
* Wed Dec 05 2012 Adam Miller <admiller@redhat.com> 1.2.4-1
- Merge pull request #681 from sosiouxme/BZ872415 (openshift+bot@redhat.com)
- rhc-server-common should not depend on rhc-common - they are independant.
  (ccoleman@redhat.com)
- rhc conf files changes to add :default_gear_capabilities BZ872415
  (lmeyer@redhat.com)

* Tue Dec 04 2012 Adam Miller <admiller@redhat.com> 1.2.3-1
- Additional fix for US3078 (abhgupta@redhat.com)

* Thu Nov 29 2012 Adam Miller <admiller@redhat.com> 1.2.2-1
- various mcollective changes getting ready for 2.2 (dmcphers@redhat.com)
- taking production.rb out of config (dmcphers@redhat.com)
- fix elif typos (dmcphers@redhat.com)
- fix desc (dmcphers@redhat.com)
- command cleanup (dmcphers@redhat.com)
- avoid timeouts on long running queries in a safe way (dmcphers@redhat.com)
- don't call status if already found stopped from bulk call
  (dmcphers@redhat.com)
- use a more reasonable large disctimeout (dmcphers@redhat.com)
- usage and exit code cleanup (dmcphers@redhat.com)
- use $? the right way (dmcphers@redhat.com)
- fix max-threads opt (dmcphers@redhat.com)
- increase disc timeout on admin ops (dmcphers@redhat.com)
- using oo-ruby (dmcphers@redhat.com)
- Merge pull request #649 from smarterclayton/bug_878328_add_instant_apps
  (openshift+bot@redhat.com)
- Bug 878328 - Wordpress and Drupal should be tagged "instant_app"
  (ccoleman@redhat.com)
- migrate all the active gears first (dmcphers@redhat.com)
- migrate active gears first (dmcphers@redhat.com)
- increment rather than assign addtl nodes (dmcphers@redhat.com)

* Sat Nov 17 2012 Adam Miller <admiller@redhat.com> 1.2.1-1
- bump_minor_versions for sprint 21 (admiller@redhat.com)

* Fri Nov 16 2012 Adam Miller <admiller@redhat.com> 1.1.9-1
- Finishing off bug 876447 (dmcphers@redhat.com)

* Thu Nov 15 2012 Adam Miller <admiller@redhat.com> 1.1.8-1
- take out test-unit (dmcphers@redhat.com)
- more ruby 1.9 changes (dmcphers@redhat.com)
- Merge pull request #621 from danmcp/master (dmcphers@redhat.com)
- added ruby193-rubygem-minitest to rhc-site (admiller@redhat.com)
- Merge pull request #615 from rajatchopra/us3069 (dmcphers@redhat.com)
- Merge pull request #619 from rmillner/BZ876712 (dmcphers@redhat.com)
- Bug 876459 (dmcphers@redhat.com)
- Add "git" to the list of blacklisted app names. (rmillner@redhat.com)
- process the timezone to pacific time for nurture last access stamps
  (rchopra@redhat.com)

* Wed Nov 14 2012 Adam Miller <admiller@redhat.com> 1.1.7-1
- Merge pull request #616 from danmcp/master (dmcphers@redhat.com)
- add additional gem deps (dmcphers@redhat.com)

* Wed Nov 14 2012 Adam Miller <admiller@redhat.com> 1.1.6-1
- Merge pull request #612 from smarterclayton/us3046_quickstarts_and_app_types
  (openshift+bot@redhat.com)
- Merge remote-tracking branch 'origin/master' into
  us3046_quickstarts_and_app_types (ccoleman@redhat.com)
- Add quickstarts to broker (ccoleman@redhat.com)
- Add Quickstart config to build (ccoleman@redhat.com)
- US3046 - Implement quickstarts in drupal and react to changes in console
  (ccoleman@redhat.com)

* Wed Nov 14 2012 Adam Miller <admiller@redhat.com> 1.1.5-1
- Merge pull request #614 from danmcp/master (openshift+bot@redhat.com)
- migration efficiency changes (dmcphers@redhat.com)
- fix aria tests (dmcphers@redhat.com)
- Fixing gemspecs (kraman@gmail.com)
- Moving plugins to Rails 3.2.8 engines (kraman@gmail.com)
- sclizing gems (dmcphers@redhat.com)
- Bug 873349 (dmcphers@redhat.com)

* Tue Nov 13 2012 Adam Miller <admiller@redhat.com> 1.1.4-1
- Merge pull request #599 from ramr/master (openshift+bot@redhat.com)
- add acceptable errors category (dmcphers@redhat.com)
- better strings (dmcphers@redhat.com)
- Change back mcollective timeout on rhc to 3 minutes. (ramr@redhat.com)
- reformat timestring and url for nurture (rchopra@redhat.com)
- Add additional timings for migrations (dmcphers@redhat.com)
- handle queues as available processors rather than preset lists
  (dmcphers@redhat.com)
- Merge pull request #595 from rajatchopra/us3069 (openshift+bot@redhat.com)
- last access time update to nurture (rchopra@redhat.com)

* Mon Nov 12 2012 Adam Miller <admiller@redhat.com> 1.1.3-1
- simplify migration logic (dmcphers@redhat.com)

* Thu Nov 08 2012 Adam Miller <admiller@redhat.com> 1.1.2-1
- Merge pull request #580 from bdecoste/master (openshift+bot@redhat.com)
- BZ873969 (bdecoste@gmail.com)
- Merge pull request #575 from bdecoste/master (openshift+bot@redhat.com)
- US2944 - CapeDwarf (bdecoste@gmail.com)
- US2944 - CapeDwarf (bdecoste@gmail.com)
- update migration to 2.0.20 (dmcphers@redhat.com)
- Fix system/app_events_test.rb (causing broker_extended to fail)
  (rpenta@redhat.com)

* Thu Nov 01 2012 Adam Miller <admiller@redhat.com> 1.1.1-1
- bump_minor_versions for sprint 20 (admiller@redhat.com)
