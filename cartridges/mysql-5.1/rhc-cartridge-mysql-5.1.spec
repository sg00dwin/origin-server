Name: rhc-cartridge-mysql-5.1
Version: 0.2
Release: 1%{?dist}
Summary: Embedded mysql support for express

Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-node >= 0.69.4
Requires: mysql-server

%description
Provides rhc perl cartridge support

%prep
%setup -q

%build
rake install:test

%install
rm -rf $RPM_BUILD_ROOT
rake DESTDIR="$RPM_BUILD_ROOT" install:all

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/embedded/mysql-5.1/

%changelog
* Wed Jun 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.2-1
- new package built with tito

* Mon May 16 2011 Mike McGrath <mmcgrath@redhat.com> 0.1-1
- Initial packaging
