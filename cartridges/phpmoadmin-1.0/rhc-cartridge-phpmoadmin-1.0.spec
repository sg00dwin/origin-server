%define cartridgedir %{_libexecdir}/li/cartridges/embedded/phpmoadmin-1.0

Name: rhc-cartridge-phpmoadmin-1.0
Version: 0.3.1
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
* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.3.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.2-1
- 

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.2.1-1
- bump spec numbers (dmcphers@redhat.com)

* Tue Nov 29 2011 Dan McPherson <dmcphers@redhat.com> 0.1.9-1
- fix for bug #758085. Failure keyword replaced with Stopped
  (rchopra@redhat.com)

* Mon Nov 28 2011 Dan McPherson <dmcphers@redhat.com> 0.1.8-1
- phpmoadmin bug fixes #756713, #756716 (rchopra@redhat.com)

* Wed Nov 23 2011 Dan McPherson <dmcphers@redhat.com> 0.1.7-1
- fixes in phpmoadmin cucumber tests (rpenta@redhat.com)
- cleanup of hooks (rchopra@redhat.com)

* Tue Nov 22 2011 Dan McPherson <dmcphers@redhat.com> 0.1.6-1
- 

* Tue Nov 22 2011 Dan McPherson <dmcphers@redhat.com> 0.1.5-1
- PhpMoAdmin cartridge changes: - Enforce user-name/password for accessing
  phpMoAdmin web console. (rpenta@redhat.com)

* Tue Nov 22 2011 Dan McPherson <dmcphers@redhat.com> 0.1.4-1
- Remove unloved [acc. to Rajat] config.inc.php file. (ramr@redhat.com)

* Mon Nov 21 2011 Rajat Chopra <rchopra@redhat.com> 0.1.3-1
- changed version number is spec file to 1.0

* Mon Nov 21 2011 Rajat Chopra <rchopra@redhat.com> 0.1.2-1
- new package built with tito

* Fri Nov 18 2011 Rajat Chopra <rchopra@redhat.com> 0.1.1-1
- new package built with tito

