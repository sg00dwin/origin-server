%define htmldir %{_localstatedir}/www/html
%define billingdir %{_localstatedir}/www/stickshift/billing

Summary:   StickShift billing components
Name:      stickshift-billing
Version:   0.0.2
Release:   1%{?dist}
Group:     System Environment/Daemons
License:   ASL 2.0
URL:       http://openshift.redhat.com
Source0:   stickshift-billing-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  httpd
Requires:  mod_ssl
Requires:  mod_passenger
Requires:  mongodb-server
Requires:  rubygem(rails)
Requires:  rubygem(xml-simple)
Requires:  rubygem(bson_ext)
Requires:  rubygem(rest-client)
Requires:  rubygem(parseconfig)
Requires:  rubygem(json)
Requires:  rubygem(stickshift-controller)
Requires:  rubygem(passenger)
Requires:  rubygem-passenger-native

BuildArch: noarch

%description
This contains the billing 'controlling' components of StickShift.
This includes the public APIs for the billing vendor.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_initddir}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{billingdir}
mkdir -p %{buildroot}%{billingdir}/httpd/run
mkdir -p %{buildroot}%{billingdir}/httpd/logs
mkdir -p %{buildroot}%{billingdir}/log
mkdir -p %{buildroot}%{billingdir}/run
mkdir -p %{buildroot}%{billingdir}/tmp/cache
mkdir -p %{buildroot}%{billingdir}/tmp/pids
mkdir -p %{buildroot}%{billingdir}/tmp/sessions
mkdir -p %{buildroot}%{billingdir}/tmp/sockets

cp -r . %{buildroot}%{billingdir}
# Uncomment once we want to enable billing service
#mv %{buildroot}%{billingdir}/init.d/* %{buildroot}%{_initddir}
ln -s %{billingdir}/public %{buildroot}%{htmldir}/billing
touch %{buildroot}%{billingdir}/log/production.log
touch %{buildroot}%{billingdir}/log/development.log
ln -sf /usr/lib64/httpd/modules %{buildroot}%{billingdir}/httpd/modules
ln -sf /etc/httpd/conf/magic %{buildroot}%{billingdir}/httpd/conf/magic

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0640,apache,apache,0750)
%attr(0666,-,-) %{billingdir}/log/production.log
%attr(0666,-,-) %{billingdir}/log/development.log
%attr(0750,-,-) %{billingdir}/script
%attr(0750,-,-) %{billingdir}/tmp
%attr(0750,-,-) %{billingdir}/tmp/cache
%attr(0750,-,-) %{billingdir}/tmp/pids
%attr(0750,-,-) %{billingdir}/tmp/sessions
%attr(0750,-,-) %{billingdir}/tmp/sockets
%{billingdir}
%{htmldir}/billing
%config(noreplace) %{billingdir}/config/environments/production.rb
%config(noreplace) %{billingdir}/config/environments/development.rb

# Uncomment once we want to enable billing service
#%defattr(0640,root,root,0750)
#%{_initddir}/stickshift-billing
#%attr(0750,-,-) %{_initddir}/stickshift-billing

%doc %{billingdir}/COPYRIGHT
%doc %{billingdir}/LICENSE

%post
/bin/touch %{billingdir}/log/production.log
/bin/touch %{billingdir}/log/development.log
/bin/touch %{billingdir}/httpd/logs/error_log
/bin/touch %{billingdir}/httpd/logs/access_log

# Uncomment once we want to enable billing service
#systemctl --system daemon-reload
#chkconfig stickshift-billing on

%changelog
* Fri May 18 2012 Ravi Sankar <rpenta@redhat.com> 0.0.2-1
- new package built with tito

