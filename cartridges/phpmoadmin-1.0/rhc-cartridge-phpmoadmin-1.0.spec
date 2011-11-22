%define cartridgedir %{_libexecdir}/li/cartridges/embedded/phpmoadmin-1.0

Name: rhc-cartridge-phpmoadmin-1.0
Version: 0.1.2
Release: 1%{?dist}
Summary: Embedded phpMoAdmin support for express

Group: Applications/Internet
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-node
Requires: rhc-cartridge-mongodb-2.0
Requires: php-devel

%description
Provides rhc phpMoAdmin cartridge support

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
cp -r info %{buildroot}%{cartridgedir}/

%post
cp %{cartridgedir}/info/configuration/etc/phpMoAdmin/config.inc.php %{_sysconfdir}/phpMoAdmin/config.inc.php

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/build/
%attr(0750,-,-) %{cartridgedir}/info/html/
%config(noreplace) %{cartridgedir}/info/configuration/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Mon Nov 21 2011 Rajat Chopra <rchopra@redhat.com> 0.1.2-1
- new package built with tito

* Fri Nov 18 2011 Rajat Chopra <rchopra@redhat.com> 0.1.1-1
- new package built with tito

