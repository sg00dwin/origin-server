%define cartridgedir %{_libexecdir}/li/cartridges/embedded/10gen-mms-agent-0.1

Name: rhc-cartridge-10gen-mms-agent-0.1
Version: 1.1.7
Release: 1%{?dist}
Summary: Embedded 10gen MMS agent for performance monitoring of MondoDB

Group: Applications/Internet
License: Free
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-node
Requires: rhc-cartridge-mongodb-2.0
Requires: pymongo
Requires: mms-agent

%description
Provides 10gen MMS agent cartridge support

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
cp -r info %{buildroot}%{cartridgedir}/
%post

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/build/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Mon Dec 12 2011 Mike McGrath <mmcgrath@redhat.com> 1.1.7-1
- modified the confirmation message to the user to reflect recent changes
  (abhgupta@redhat.com)
- adding cucumber test scripts and validating for the existence of settings.py
  file before embedding 10gen-mms-agent-0.1 (abhgupta@redhat.com)

* Sun Dec 11 2011 Dan McPherson <dmcphers@redhat.com> 1.1.6-1
- fixes to 10gen mms agent configure script for stopping the agent process
  (abhgupta@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (abhgupta@redhat.com)
- changes to 10gen mms agent cartridge hooks (abhgupta@redhat.com)

* Fri Dec 09 2011 Alex Boone <aboone@redhat.com> 1.1.5-1
- proper cartridge requirements (mmcgrath@redhat.com)

* Fri Dec 09 2011 Mike McGrath <mmcgrath@redhat.com> 1.1.4-1
- adding rhc-cartridge-10gen-mms-agent-0.1 to the devenv spec file to be
  installed on the devenv  and adding the dependency on mms-agent source rpm on
  the rhc-cartridge-10gen-mms-agent-0.1 spec file (abhgupta@redhat.com)

* Fri Dec 09 2011 Mike McGrath <mmcgrath@redhat.com> 1.1.3-1
- merging with conflicting changes (abhgupta@redhat.com)
- changes based on name change of the source rpm package (abhgupta@redhat.com)
- temp removal until it's avaialble (mmcgrath@redhat.com)
- removing mms agent source code from the cartridge (abhgupta@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (abhgupta@redhat.com)
- accidentally checked in the php app directory (abhgupta@redhat.com)

* Thu Dec 08 2011 Mike McGrath <mmcgrath@redhat.com> 1.1.2-1
- new package built with tito


