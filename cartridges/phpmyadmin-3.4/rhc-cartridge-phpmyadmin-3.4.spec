%define cartridgedir %{_libexecdir}/li/cartridges/embedded/phpmyadmin-3.4

Name: rhc-cartridge-phpmyadmin-3.4
Version: 0.1.1
Release: 1%{?dist}
Summary: Embedded phpMyAdmin support for express

Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-broker >= 0.73.4
Requires: phpMyAdmin

%description
Provides rhc phpMyAdmin cartridge support

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


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/build/
%config(noreplace) %{cartridgedir}/info/configuration/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Wed Oct 05 2011 Thomas Wiest <twiest@redhat.com> 0.1.1-1
- new package built with tito

* Wed Oct  5 2011 Thomas Wiest <twiest@redhat.com> 0.1-1
- Initial packaging
