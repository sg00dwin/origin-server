%define cartridgedir %{_libexecdir}/li/cartridges/embedded/mysql-5.1

Name: rhc-cartridge-mysql-5.1
Version: 0.19.1
Release: 1%{?dist}
Summary: Embedded mysql support for express

Group: Network/Daemons
License: ASL V2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-node
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
* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.19.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.18.7-1
- fix build breaks (dmcphers@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.18.6-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- Cleanup error message to indicate only 1 embedded database is permitted per
  application. (ramr@redhat.com)
- basic descriptors for all cartridges; added primitive structure for a www-
  dynamic cartridge that will abstract all httpd processes that any cartridges
  need (e.g. php, perl, metrics, rockmongo etc). (rchopra@redhat.com)
- Display errors if there's already a database embedded within the app + on
  deconfigure only cleanup if we "owned" the configuration. (ramr@redhat.com)
