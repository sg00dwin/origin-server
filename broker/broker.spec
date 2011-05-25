%define htmldir %{_localstatedir}/www/html
%define brokerdir %{_localstatedir}/www/libra/broker

Name: rhc-broker
Version: 0.72.1
Release: 2%{?dist}
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-broker-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Summary: Li broker components
Group: Network/Daemons
BuildArch: noarch
Requires: rhc-common
Requires: rhc-server-common
Requires: httpd
Requires: mod_passenger
Requires: rubygem-passenger-native-libs
Requires: rubygem-rails
Requires: rubygem-json
Requires: rubygem-parseconfig
Requires: rubygem-aws
Requires: rubygem-xml-simple

%description
This contains the broker 'controlling' components of OpenShift.
This includes the public APIs for the client tools.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{brokerdir}
cp -r . %{buildroot}%{brokerdir}
ln -s %{brokerdir}/public %{buildroot}%{htmldir}/broker

mkdir -p %{buildroot}%{brokerdir}/log
touch %{buildroot}%{brokerdir}/log/production.log


%clean
rm -rf $RPM_BUILD_ROOT

%pre
/usr/sbin/groupadd -r libra_user 2>&1 || :
/usr/sbin/useradd libra_passenger -g libra_user \
                                  -d /var/lib/passenger \
                                  -r \
                                  -s /sbin/nologin 2>&1 > /dev/null || :

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,-,-) %{brokerdir}/log/production.log
%ghost %{brokerdir}/log/production.log
%config %{brokerdir}/config/environments/production.rb
%{brokerdir}
%{htmldir}/broker

%post
/bin/touch %{brokerdir}/log/production.log

%changelog
* Wed May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Fixing sym link to buildroot (mhicks@redhat.com)

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72-1
- Initial refactoring
