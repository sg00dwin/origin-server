%define htmldir %{_localstatedir}/www/html
%define sitedir %{_localstatedir}/www/libra/site

Name: rhc-site
Version: 0.70.2
Release: 1%{?dist}
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-site-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Summary: Li site components
Group: Network/Daemons
BuildArch: noarch
Requires: rhc-common
Requires: httpd
Requires: mod_passenger
Requires: rubygem-passenger-native-libs
Requires: rubygem-rails
Requires: rubygem-json
Requires: rubygem-parseconfig
Requires: rubygem-aws
Requires: rubygem-xml-simple
Requires: rubygem-formtastic
Requires: rubygem-haml

%description
This contains the OpenShift website which manages user authentication,
authorization and also the workflows to request access.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{sitedir}
cp -r . %{buildroot}%{sitedir}
ln -s %{buildroot}%{sitedir}/public %{buildroot}%{htmldir}/broker

mkdir -p %{buildroot}%{sitedir}/log
touch %{buildroot}%{sitedir}/log/production.log

%clean
rm -rf %{buildroot}

%pre
/usr/sbin/groupadd -r libra_user 2>&1 || :
/usr/sbin/useradd libra_passenger -g libra_user \
                                  -d /var/lib/passenger \
                                  -r \
                                  -s /sbin/nologin 2>&1 > /dev/null || :

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,root,libra_user) %{sitedir}/log/production.log
%ghost %{sitedir}/log/production.log
%config %{sitedir}/config/environments/production.rb
%{sitedir}
%{htmldir}/site

%post
/bin/touch %{sitedir}/log/production.log

%changelog
