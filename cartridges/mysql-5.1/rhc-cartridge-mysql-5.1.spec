%define cartridgedir %{_libexecdir}/li/cartridges/embedded/mysql-5.1

Name: rhc-cartridge-mysql-5.1
Version: 0.6
Release: 1%{?dist}
Summary: Embedded mysql support for express

Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-broker >= 0.73.4
Requires: mysql-server

%description
Provides rhc perl cartridge support

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
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Tue Jul 05 2011 Dan McPherson <dmcphers@redhat.com> 0.6-1
- Altering binding detection method (mmcgrath@redhat.com)

* Thu Jun 30 2011 Dan McPherson <dmcphers@redhat.com> 0.5-1
- moving runcons (mmcgrath@redhat.com)
- fixing start/stop (mmcgrath@redhat.com)

* Wed Jun 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.4-1
- 

* Wed Jun 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.3-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- undo passing rhlogin to cart (dmcphers@redhat.com)
- merged (mmcgrath@redhat.com)
- Adding mysql (mmcgrath@redhat.com)

* Wed Jun 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.2-1
- new package built with tito

* Wed Jun 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.1-1
- Initial packaging
