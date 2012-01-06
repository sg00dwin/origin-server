%define cartridgedir %{_libexecdir}/li/cartridges/embedded/phpmyadmin-3.4

Name: rhc-cartridge-phpmyadmin-3.4
Version: 0.6.3
Release: 1%{?dist}
Summary: Embedded phpMyAdmin support for express

Group: Applications/Internet
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-node
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

%post
cp %{cartridgedir}/info/configuration/etc/phpMyAdmin/config.inc.php %{_sysconfdir}/phpMyAdmin/config.inc.php

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/build/
%config(noreplace) %{cartridgedir}/info/configuration/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%attr(0755,-,-) %{cartridgedir}/info/html/
%attr(0644,-,-) %{cartridgedir}/info/html/*
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.6.3-1
- Bug 772173 (dmcphers@redhat.com)

* Thu Jan 05 2012 Dan McPherson <dmcphers@redhat.com> 0.6.2-1
- mysql and mongo move (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.6.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.5.2-1
- 

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.5.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Nov 18 2011 Dan McPherson <dmcphers@redhat.com> 0.4.5-1
- moving logic to abstract from li-controller (dmcphers@redhat.com)

* Fri Nov 18 2011 Dan McPherson <dmcphers@redhat.com> 0.4.4-1
- more php settings + mirage devenv additions (dmcphers@redhat.com)

* Tue Nov 15 2011 Dan McPherson <dmcphers@redhat.com> 0.4.3-1
- increasing max filesize (mmcgrath@redhat.com)

* Sat Nov 12 2011 Dan McPherson <dmcphers@redhat.com> 0.4.2-1
- remove carts dep on broker (dmcphers@redhat.com)

* Thu Nov 10 2011 Dan McPherson <dmcphers@redhat.com> 0.4.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Nov 07 2011 Thomas Wiest <twiest@redhat.com> 0.3.6-1
- phpmyadmin: fixed html directory perms (twiest@redhat.com)

* Sat Nov 05 2011 Dan McPherson <dmcphers@redhat.com> 0.3.5-1
- fix build break (dmcphers@redhat.com)

* Sat Nov 05 2011 Dan McPherson <dmcphers@redhat.com> 0.3.4-1
- Fix for bug 749751 (twiest@redhat.com)

* Thu Nov 03 2011 Dan McPherson <dmcphers@redhat.com> 0.3.3-1
- abstract move into each cart and embedded cart (dmcphers@redhat.com)

* Thu Nov 03 2011 Dan McPherson <dmcphers@redhat.com> 0.3.2-1
- moving of embedded apps (dmcphers@redhat.com)
- split out deploy httpd proxy/config for embedded apps, change stop to stop
  all for ctl-app and deconfigure and stop and start to all for pre/post
  receive (dmcphers@redhat.com)

* Thu Oct 27 2011 Dan McPherson <dmcphers@redhat.com> 0.3.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Oct 26 2011 Dan McPherson <dmcphers@redhat.com> 0.2.8-1
- 

* Wed Oct 26 2011 Dan McPherson <dmcphers@redhat.com> 0.2.7-1
- new package built with tito

* Mon Oct 17 2011 Dan McPherson <dmcphers@redhat.com> 0.2.5-1
- remove debug (dmcphers@redhat.com)

* Sun Oct 16 2011 Dan McPherson <dmcphers@redhat.com> 0.2.4-1
- abstract out remainder of deconfigure (dmcphers@redhat.com)

* Sat Oct 15 2011 Dan McPherson <dmcphers@redhat.com> 0.2.3-1
- abstract out common vars in remaining hooks (dmcphers@redhat.com)
- more abstracting (dmcphers@redhat.com)
- add an include (dmcphers@redhat.com)
- more abstracting (dmcphers@redhat.com)
- more abstracting of common code (dmcphers@redhat.com)
- move sources to the top and abstract out error method (dmcphers@redhat.com)
- move simple functions to source files (dmcphers@redhat.com)
- in the phpmyadmin configure script, moved the check for the proxy pass
  directory to the top so that if it fails, there's nothing to clean up
  (twiest@redhat.com)
- changed verbage for phpmyadmin stop (to match other carts)
  (twiest@redhat.com)
- Added wait in the phpmyadmin ctl stop script (fixes bug where stop test
  fails) (twiest@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.2-1
- Bug 746182 (dmcphers@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.2.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.1.5-1
- abstract out find_open_ip (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.1.4-1
- Bug 745373 and remove sessions where not needed (dmcphers@redhat.com)

* Sun Oct 09 2011 Dan McPherson <dmcphers@redhat.com> 0.1.3-1
- Bug 744375 (dmcphers@redhat.com)

* Wed Oct 05 2011 Thomas Wiest <twiest@redhat.com> 0.1.2-1
- Added %post entry for phpMyAdmin config.inc.php file (twiest@redhat.com)
- add concept of CLIENT_ERROR and use from phpmyadmin (dmcphers@redhat.com)

* Wed Oct 05 2011 Thomas Wiest <twiest@redhat.com> 0.1.1-1
- new package built with tito

* Wed Oct  5 2011 Thomas Wiest <twiest@redhat.com> 0.1-1
- Initial packaging
