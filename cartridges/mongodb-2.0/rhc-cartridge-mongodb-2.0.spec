%define cartridgedir %{_libexecdir}/li/cartridges/embedded/mongodb-2.0

Name: rhc-cartridge-mongodb-2.0
Version: 0.12.4
Release: 1%{?dist}
Summary: Embedded mongodb support for express

Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-node
Requires: mongodb-server
Requires: mongodb-devel
Requires: libmongodb
Requires: mongodb

%description
Provides rhc mongodb cartridge support

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
%attr(0755,-,-) %{cartridgedir}/info/lib/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Thu Jan 05 2012 Dan McPherson <dmcphers@redhat.com> 0.12.4-1
- move improvements (dmcphers@redhat.com)

* Thu Jan 05 2012 Dan McPherson <dmcphers@redhat.com> 0.12.3-1
- mysql and mongo move (dmcphers@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.12.2-1
- Remove unneeded fi. (ramr@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.12.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Dec 08 2011 Alex Boone <aboone@redhat.com> 0.11.4-1
- fix to alleviate bugz 756719 (ramr@redhat.com)

* Mon Dec 05 2011 Alex Boone <aboone@redhat.com> 0.11.3-1
- 

* Mon Dec 05 2011 Alex Boone <aboone@redhat.com> 0.11.2-1
- change message to use rockmongo in lieu of phpmoadmin to manage MongoDB
  (ramr@redhat.com)

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.11.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Nov 28 2011 Dan McPherson <dmcphers@redhat.com> 0.10.2-1
- Fix for bugz 756722 -- mongorestore does the equivalent of inserts, so need
  to drop and recreate db in order for collections to be restored.
  (ramr@redhat.com)

* Wed Nov 23 2011 Dan McPherson <dmcphers@redhat.com> 0.10.1-1
- change to 3 digit version num (dmcphers@redhat.com)

* Wed Nov 23 2011 Dan McPherson <dmcphers@redhat.com> 0.9-1
- 

* Wed Nov 23 2011 Ram Ranganathan <ramr@redhat.com> 0.8-1
- minor message cleanup. (ramr@redhat.com)
- NOSQL prefix to demarcate "namespace/dbtype". (ramr@redhat.com)

* Sat Nov 19 2011 Dan McPherson <dmcphers@redhat.com> 0.7-1
- start mongod for mongorestore to work - also don't suppress errors.
  (ramr@redhat.com)
- mongodb dump and restore functions (ramr@redhat.com)

* Fri Nov 18 2011 Ram Ranganathan <ramr@redhat.com> 0.7-1
- mongodb dump and restore functions

* Fri Nov 18 2011 Dan McPherson <dmcphers@redhat.com> 0.6-1
- moving logic to abstract from li-controller (dmcphers@redhat.com)

* Wed Nov 16 2011 Dan McPherson <dmcphers@redhat.com> 0.5-1
- fix stop/start issue + add convenience user to db '$app' (ramr@redhat.com)
- authorization support + turn off http interface. (ramr@redhat.com)

* Wed Nov 16 2011 Ram Ranganathan <ramr@redhat.com> 0.5-2
- fix stop/start issue + add convenience user to db '$app'

* Wed Nov 16 2011 Ram Ranganathan <ramr@redhat.com> 0.5-1
- authorization support + turn off http interface

* Tue Nov 15 2011 Dan McPherson <dmcphers@redhat.com> 0.4-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- disable journal for embedded (mmcgrath@redhat.com)

* Tue Nov 15 2011 Dan McPherson <dmcphers@redhat.com> 0.3-1
- Merge branch 'master' of ssh://express-master/srv/git/li (ramr@redhat.com)
- increasing max filesize (mmcgrath@redhat.com)
- fixup hooks - start/stop/restart/configure + add "scaffolding" for running
  mongo w/ auth - admin user. (ramr@redhat.com)

* Tue Nov 15 2011 Ram Ranganathan <ramr@redhat.com> 0.2-2
- admin user [for auth], plus fixup start/stop/restart/configure hooks

* Tue Nov 15 2011 Mike McGrath <mmcgrath@redhat.com> 0.2-1
- new package built with tito

* Mon Nov 14 2011 Dan McPherson <mmcgrath@redhat.com> 0.1-1
- Initial packaging
