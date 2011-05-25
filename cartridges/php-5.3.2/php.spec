Name: rhc-cartridge-php-5.3.2
Version: 0.70.2
Release: 1%{?dist}
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-cartridge-php-5.3.2-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Summary: Provides php-5.3.2 support
Group: Development/Languages
Requires: rhc-node
Requires: php >= 5.3.2
Requires: mod_bw
Requires: rubygem-builder
Requires: php-pdo
Requires: php-gd
Requires: php-xml
Requires: php-mysql
Requires: php-pgsql

%description
Provides php support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
CARTRIDGE_DIR=$RPM_BUILD_ROOT/usr/libexec/li/cartridges/php-5.3.2
mkdir -p $CARTRIDGE_DIR
cp -r . $CARTRIDGE_DIR
chmod 0750 $CARTRIDGE_DIR/info/hooks/
chmod 0750 $CARTRIDGE_DIR/info/data/
chmod 0750 $CARTRIDGE_DIR/info/build/

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/php-5.3.2/