Name: rhc-cartridge-rack-1.1.0
Version: 0.72.1
Release: 1%{?dist}
Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-cartridge-rack-1.1.0-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Summary: Provides ruby rack support running on Phusion Passenger
Group: Development/Languages
Requires: rhc-node
Requires: httpd
Requires: mod_bw
Requires: ruby
Requires: rubygems
Requires: rubygem-rack = 1:1.1.0
Requires: rubygem-passenger
Requires: rubygem-passenger-native
Requires: rubygem-passenger-native-libs
Requires: mod_passenger
Requires: rubygem-bundler
Requires: rubygem-sqlite3
Requires: ruby-sqlite3
Requires: ruby-mysql
Requires: ruby-nokogiri

%description
Provides rack support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
CARTRIDGE_DIR=$RPM_BUILD_ROOT/usr/libexec/li/cartridges/rack-1.1.0
mkdir -p $CARTRIDGE_DIR
cp -r . $CARTRIDGE_DIR
chmod 0750 $CARTRIDGE_DIR/info/hooks/
chmod 0750 $CARTRIDGE_DIR/info/data/
chmod 0750 $CARTRIDGE_DIR/info/build/


%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/rack-1.1.0/