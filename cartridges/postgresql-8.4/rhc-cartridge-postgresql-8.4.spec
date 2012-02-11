%define cartridgedir %{_libexecdir}/li/cartridges/embedded/postgresql-8.4

Name: rhc-cartridge-postgresql-8.4
Version: 0.3.2
Release: 1%{?dist}
Summary: Embedded postgresql support for express

Group: Network/Daemons
License: ASL 2.0
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-node
Requires: postgresql
Requires: postgresql-server
Requires: postgresql-libs
Requires: postgresql-devel
Requires: postgresql-ip4r
Requires: postgresql-jdbc
Requires: postgresql-plperl
Requires: postgresql-plpython
Requires: postgresql-pltcl
Requires: PyGreSQL
Requires: perl-Class-DBI-Pg
Requires: perl-DBD-Pg
Requires: perl-DateTime-Format-Pg
Requires: php-pear-MDB2-Driver-pgsql
Requires: php-pgsql
Requires: postgis
Requires: python-psycopg2
Requires: ruby-postgres
Requires: rhdb-utils
Requires: uuid-pgsql


%description
Provides rhc postgresql cartridge support

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
cp LICENSE %{buildroot}%{cartridgedir}/
cp COPYRIGHT %{buildroot}%{cartridgedir}/

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
%{cartridgedir}/info/manifest.yml
%doc %{cartridgedir}/COPYRIGHT
%doc %{cartridgedir}/LICENSE

%changelog
* Sat Feb 11 2012 Dan McPherson <dmcphers@redhat.com> 0.3.2-1
- more abstracting out selinux (dmcphers@redhat.com)
- first pass at splitting out selinux logic (dmcphers@redhat.com)
- Updating models to improove schems of descriptor in mongo Moved
  connection_endpoint to broker (kraman@gmail.com)
- Fixing manifest yml files (kraman@gmail.com)
- Creating models for descriptor Fixing manifest files Added command to list
  installed cartridges and get descriptors (kraman@gmail.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- change status to use normal client_result instead of special handling
  (dmcphers@redhat.com)
- Cleanup usage message to include status and fix bug - missing cat.
  (ramr@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.3.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Feb 01 2012 Dan McPherson <dmcphers@redhat.com> 0.2.5-1
- Remove extraneous chcon (thanks dmcphers) - we do this again after db
  initialization. (ramr@redhat.com)
- fix postgres move and other selinux move fixes (dmcphers@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.2.4-1
- deploy httpd proxy from migration (dmcphers@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.2.3-1
- Updated License value in manifest.yml files. Corrected Apache Software
  License Fedora short name (jhonce@redhat.com)
- postgresql-8.4: Modified license to ASL V2 (jhonce@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.2.2-1
- reducto 'footprint'. (ramr@redhat.com)
- Revert commit by build/devenv. (ramr@redhat.com)
- Temporary commit to build (ramr@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Update license information. (ramr@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.2.1-1
- bump spec numbers (dmcphers@redhat.com)

* Tue Jan 10 2012 Dan McPherson <dmcphers@redhat.com> 0.1.5-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- descriptor file for postgresql (rchopra@redhat.com)
- Disable phpPgAdmin message on adding postgres cartridge. (mpatel@redhat.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.1.4-1
- Add ruby postgres driver. (ramr@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.1.3-1
- Cleanup error message to indicate only 1 embedded database is permitted per
  application. (ramr@redhat.com)
- Error code collision!! (ramr@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.1.2-1
- new package built with tito

* Thu Dec 22 2011 Ram Ranganathan <ramr@redhat.com> 0.1-1
- Initial packaging
