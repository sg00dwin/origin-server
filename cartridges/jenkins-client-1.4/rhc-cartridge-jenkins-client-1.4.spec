%define cartridgedir %{_libexecdir}/li/cartridges/embedded/jenkins-client-1.4

Name: rhc-cartridge-jenkins-client-1.4
Version: 0.14.4
Release: 1%{?dist}
Summary: Embedded jenkins client support for express 
Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-broker >= 0.73.4
Requires: mysql-devel
Requires: wget
Requires: java-1.6.0-openjdk

%description
Provides embedded jenkins client support

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
* Sat Oct 15 2011 Dan McPherson <dmcphers@redhat.com> 0.14.4-1
- abstract out common vars in remaining hooks (dmcphers@redhat.com)
- more abstracting (dmcphers@redhat.com)
- more abstracting (dmcphers@redhat.com)
- move sources to the top and abstract out error method (dmcphers@redhat.com)
- move simple functions to source files (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.14.3-1
- add simple jenkins client status - just a url (dmcphers@redhat.com)
- more app_ctl fixes (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.14.2-1
- Bug 746182 (dmcphers@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.14.1-1
- bump spec numbers (dmcphers@redhat.com)
- make jenkins client spec 3 digits (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.12-1
- Bug 745373 and remove sessions where not needed (dmcphers@redhat.com)
- Bug 745401 (dmcphers@redhat.com)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.11-1
- mv pw to password-file and create jenkins-client-1.4 dir
  (dmcphers@redhat.com)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.10-1
- add authentication to jenkins (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.9-1
- add .m2 syncing (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.8-1
- Altering embedding behavior on failure (mmcgrath@redhat.com)
- Adding error output for client (mmcgrath@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.7-1
- add deploy step and call from jenkins with stop start (dmcphers@redhat.com)
- adding UUID and DNS support (mmcgrath@redhat.com)

* Thu Oct 06 2011 Dan McPherson <dmcphers@redhat.com> 0.6-1
- fix merge (dmcphers@redhat.com)
- fix merge (dmcphers@redhat.com)
- missed a couple of env vars (dmcphers@redhat.com)
- use cartridge specific or fall back to default job.xml (mmcgrath@redhat.com)
- add back in jenkins_url (dmcphers@redhat.com)
- adding raw type for default builder (mmcgrath@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.5-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Adding git upstream automation (mmcgrath@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.4-1
- removing explicit CI URL call (mmcgrath@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.3-1
- fixing path order (mmcgrath@redhat.com)

* Thu Sep 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.2-1
- new package built with tito

* Thu Sep 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.1-1
- Initial packaging
