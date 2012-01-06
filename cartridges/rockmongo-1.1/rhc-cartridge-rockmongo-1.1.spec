%define cartridgedir %{_libexecdir}/li/cartridges/embedded/rockmongo-1.1

Name: rhc-cartridge-rockmongo-1.1
Version: 1.2.3
Release: 1%{?dist}
Summary: Embedded RockMongo support for express

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
Provides rhc RockMongo cartridge support

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

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/build/
%attr(0750,-,-) %{cartridgedir}/info/html/
%config(noreplace) %{cartridgedir}/info/configuration/
%attr(0755,-,-) %{cartridgedir}/info/bin/
 %{cartridgedir}/info/rockmongo/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 1.2.3-1
- Bug 772173 (dmcphers@redhat.com)

* Thu Jan 05 2012 Dan McPherson <dmcphers@redhat.com> 1.2.2-1
- mysql and mongo move (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 1.2.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 1.1.3-1
- 

* Fri Dec 09 2011 Mike McGrath <mmcgrath@redhat.com> 1.1.2-1
- whitelist change for rebuild (mmcgrath@redhat.com)
- fix for bug#760008 (rchopra@redhat.com)
- release bump (mmcgrath@redhat.com)
- adding rockmongo dir, should be separated out later (mmcgrath@redhat.com)

* Fri Dec 02 2011 Mike McGrath <mmcgrath@redhat.com> 1.1.1-2
- Correcting spec

* Fri Dec 02 2011 Mike McGrath <mmcgrath@redhat.com> 1.1.1-1
- new package built with tito

