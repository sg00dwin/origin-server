%define cartridgedir %{_libexecdir}/li/cartridges/embedded/mysql-5.1

Name: rhc-cartridge-mysql-5.1
Version: 0.10.4
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
Requires: mysql-devel

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
* Thu Aug 11 2011 Matt Hicks <mhicks@redhat.com> 0.10.4-1
- storing dump in data dir (mmcgrath@redhat.com)

* Tue Aug 09 2011 Dan McPherson <dmcphers@redhat.com> 0.10.3-1
- changing order of operations for mysql creation (mmcgrath@redhat.com)
- changing order and better error (mmcgrath@redhat.com)
- Adding application name (mmcgrath@redhat.com)

* Mon Aug 08 2011 Dan McPherson <dmcphers@redhat.com> 0.10.2-1
- correcting wildcard globbing and dump path (mmcgrath@redhat.com)
- correcting wildcard glob usage (mmcgrath@redhat.com)
- Adding dump/restore scripts (mmcgrath@redhat.com)
- Adding dump and restore commands (mmcgrath@redhat.com)

* Fri Aug 05 2011 Dan McPherson <dmcphers@redhat.com> 0.10.1-1
- bump spec numbers (dmcphers@redhat.com)

* Tue Aug 02 2011 Dan McPherson <dmcphers@redhat.com> 0.9.6-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- remove environment variables after removing mysql (mmcgrath@redhat.com)

* Sun Jul 31 2011 Dan McPherson <dmcphers@redhat.com> 0.9.5-1
- 

* Sun Jul 31 2011 Dan McPherson <dmcphers@redhat.com> 0.9.4-1
- removed "/php/" from APP_DIR (markllama@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.9.3-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- correcting mysql version (mmcgrath@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.9.2-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Adding mysql ctl start script (mmcgrath@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.9.1-1
- Adding mysql environment variables (mmcgrath@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- add server identity and namespace auto migrate (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- adding mysql-devel (mmcgrath@redhat.com)

* Mon Jul 18 2011 Dan McPherson <dmcphers@redhat.com> 0.8.4-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- call pam_namespace (mmcgrath@redhat.com)
- 722836 (dmcphers@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.8.3-1
- setup mysql to restart with correct deps (mmcgrath@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.8.2-1
- Automatic commit of package [rhc-cartridge-mysql-5.1] release [0.8.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-mysql-5.1] release [0.7.2-1].
  (dmcphers@redhat.com)
- update version number on mysql to be 3 digits (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-mysql-5.1] release [0.7-1].
  (dmcphers@redhat.com)
- fixing mysql to work with rack (mmcgrath@redhat.com)
- Automatic commit of package [rhc-cartridge-mysql-5.1] release [0.6-1].
  (dmcphers@redhat.com)
- Altering binding detection method (mmcgrath@redhat.com)
- Automatic commit of package [rhc-cartridge-mysql-5.1] release [0.5-1].
  (dmcphers@redhat.com)
- moving runcons (mmcgrath@redhat.com)
- fixing start/stop (mmcgrath@redhat.com)
- Automatic commit of package [rhc-cartridge-mysql-5.1] release [0.4-1].
  (mmcgrath@redhat.com)
- Automatic commit of package [rhc-cartridge-mysql-5.1] release [0.3-1].
  (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- undo passing rhlogin to cart (dmcphers@redhat.com)
- merged (mmcgrath@redhat.com)
- Adding mysql (mmcgrath@redhat.com)
- Automatic commit of package [rhc-cartridge-mysql-5.1] release [0.2-1].
  (mmcgrath@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)
- Adding MYSQL_DIR and changing dir location from ~/appname/mysql to ~/mysql/
  (mmcgrath@redhat.com)
- Added mysql cartridge (mmcgrath@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.8.1-1
- bumping spec numbers (dmcphers@redhat.com)

* Thu Jul 07 2011 Dan McPherson <dmcphers@redhat.com> 0.7.2-1
- update version number on mysql to be 3 digits (dmcphers@redhat.com)

* Wed Jul 06 2011 Dan McPherson <dmcphers@redhat.com> 0.7-1
- fixing mysql to work with rack (mmcgrath@redhat.com)

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
