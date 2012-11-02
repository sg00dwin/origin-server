%define htmldir %{_localstatedir}/www/html
%define brokerdir %{_localstatedir}/www/openshift/broker

Summary:   Li broker components
Name:      rhc-broker
Version: 1.1.0
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
Requires:  rubygem-openshift-origin-controller
Requires:  rubygem-bson_ext
Requires:  rubygem-rest-client
Requires:  rubygem-thread-dump
Requires:  rubygem-openshift-origin-auth-streamline
Requires:  rubygem-openshift-origin-dns-dynect
Requires:  rubygem-openshift-origin-msg-broker-mcollective
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
# As broker admin scripts are opensourced they are placed into this package
Requires:  openshift-origin-broker-util
Provides:  openshift-broker

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
mkdir -p %{buildroot}%{_localstatedir}/log/openshift

mv %{buildroot}%{brokerdir}/script/rhc-admin-cartridge-do %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-migrate %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-usage %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-plan %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-chk %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-stale-dns %{buildroot}/%{_bindir}

cp conf/broker.conf %{buildroot}/etc/openshift/
cp conf/broker-dev.conf %{buildroot}/etc/openshift/
cp conf/openshift-origin-msg-broker-mcollective-dev.conf %{buildroot}/etc/openshift/plugins.d/
cp conf/openshift-origin-msg-broker-mcollective.conf %{buildroot}/etc/openshift/plugins.d/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0640,root,libra_user,0750)
%ghost %attr(0660,root,root) %{brokerdir}/log/production.log
%ghost %attr(0660,root,root) %{_localstatedir}/log/openshift/user_action.log
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
%attr(0750,-,-) %{_bindir}/rhc-admin-chk
%attr(0750,-,-) %{_bindir}/rhc-admin-cartridge-do
%attr(0750,-,-) %{_bindir}/rhc-admin-migrate
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-usage
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-plan
%attr(0750,-,-) %{_bindir}/rhc-admin-stale-dns
/usr/lib/openshift/broker/application_templates

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
* Thu Nov 01 2012 Adam Miller <admiller@redhat.com> 1.0.2-1
- Remove dev templates (ironcladlou@gmail.com)

* Tue Oct 30 2012 Adam Miller <admiller@redhat.com> 1.0.1-1
- bumping specs to at least 1.0.0 (dmcphers@redhat.com)

* Mon Oct 29 2012 Adam Miller <admiller@redhat.com> 0.99.20-1
- Converted dynect and streamline plugins to rails engines Moved plugin config
  into /etc/openshift/plugins.d Moved broker global conf to
  /etc/openshift/broker.conf Modified broker and plugins to loca *-dev.conf
  files when in development environment Mofied broker to switch to dev
  environment with /etc/openshift/development flag is present
  (kraman@gmail.com)

* Fri Oct 26 2012 Adam Miller <admiller@redhat.com> 0.99.19-1
- Merge pull request #526 from ironcladlou/drupal-typeless
  (openshift+bot@redhat.com)
- topping the bz868570 fix for subaccounts (rchopra@redhat.com)
- Fix fork repo reference for drupal template (ironcladlou@gmail.com)

* Wed Oct 24 2012 Adam Miller <admiller@redhat.com> 0.99.18-1
- rsync key path pulled in as part of the config file (rchopra@redhat.com)
- Merge pull request #516 from ironcladlou/dev/typeless
  (openshift+bot@redhat.com)
- Bug 868858 (dmcphers@redhat.com)
- Add development templates for typeless gears (ironcladlou@gmail.com)
- RHC client compatibility fix for application lookups (ironcladlou@gmail.com)

* Mon Oct 22 2012 Adam Miller <admiller@redhat.com> 0.99.17-1
- removing remaining cases of SS and config.ss (dmcphers@redhat.com)

* Fri Oct 19 2012 Adam Miller <admiller@redhat.com> 0.99.16-1
- Merge pull request #501 from pmorie/dev/rename (dmcphers@redhat.com)
- Changes for 2.0.19 migrations (pmorie@gmail.com)

* Thu Oct 18 2012 Adam Miller <admiller@redhat.com> 0.99.15-1
- Fixed template rake tasks to work with new REST API stuff (fotios@redhat.com)

* Tue Oct 16 2012 Adam Miller <admiller@redhat.com> 0.99.14-1
- Merge pull request #489 from tkramer-
  rh/dev/tkramer/security/user_action_and_production_log (dmcphers@redhat.com)
- Merge pull request #487 from rajatchopra/master (dmcphers@redhat.com)
- Security - fix user_action and production logs to root root 0660 and fixed
  the last line in the change log (tkramer@redhat.com)
- Security - changes user_action.log and production.log to be root root 0660
  (tkramer@redhat.com)
- update error codes; user-agent in nurture info (rchopra@redhat.com)

* Mon Oct 15 2012 Adam Miller <admiller@redhat.com> 0.99.13-1
- fix extended tests (rchopra@redhat.com)
- Bug 863575 (dmcphers@redhat.com)

* Mon Oct 08 2012 Adam Miller <admiller@redhat.com> 0.99.12-1
- Refactorings needed to share the generate_broker_key logic with Origin
  (bleanhar@redhat.com)
- Fixing renames, paths, configs and cleaning up old packages. Adding
  obsoletes. (kraman@gmail.com)

* Thu Oct 04 2012 Adam Miller <admiller@redhat.com> 0.99.11-1
- Merge pull request #438 from brenton/remove_os_scripts2
  (openshift+bot@redhat.com)
- Merging in the latest from master (bleanhar@redhat.com)
- Merging in the latest from master (bleanhar@redhat.com)
- The openshift-origin-broker-util packages provides the newly renamed admin scripts (bleanhar@redhat.com)
