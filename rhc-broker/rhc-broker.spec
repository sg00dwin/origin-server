%define htmldir %{_localstatedir}/www/html
%define brokerdir %{_localstatedir}/www/openshift/broker

Summary:   Li broker components
Name:      rhc-broker
Version: 0.99.11
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

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0640,root,libra_user,0750)
%ghost %{brokerdir}/log/production.log
%ghost %{_localstatedir}/log/openshift/user_action.log
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
* Thu Oct 04 2012 Adam Miller <admiller@redhat.com> 0.99.11-1
- Merge pull request #438 from brenton/remove_os_scripts2
  (openshift+bot@redhat.com)
- Merging in the latest from master (bleanhar@redhat.com)
- Merging in the latest from master (bleanhar@redhat.com)
- The openshift-origin-broker-util packages provides the newly renamed admin
  scripts (bleanhar@redhat.com)