%define cartridgedir %{_libexecdir}/li/cartridges/embedded/jenkins-client-1.4

Name: rhc-cartridge-jenkins-client-1.4
Version: 0.6
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
