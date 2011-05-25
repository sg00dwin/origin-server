Name: rhc-cartridge-wsgi-3.2.1
Version: 0.72.1
Release: 1%{?dist}
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-cartridge-wsgi-3.2.1-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Summary: Provides python-wsgi-3.2.1 support
Group: Development/Languages
Requires: rhc-node
Requires: httpd
Requires: mod_bw
Requires: python
Requires: mod_wsgi = 3.2
Requires: MySQL-python
Requires: python-psycopg2

%description
Provides wsgi support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
CARTRIDGE_DIR=$RPM_BUILD_ROOT/usr/libexec/li/cartridges/wsgi-3.2.1
mkdir -p $CARTRIDGE_DIR
cp -r . $CARTRIDGE_DIR
chmod 0750 $CARTRIDGE_DIR/info/hooks/
chmod 0750 $CARTRIDGE_DIR/info/data/
chmod 0750 $CARTRIDGE_DIR/info/build/


%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/wsgi-3.2.1/