Name: rhc-cartridge-jbossas-7.0.0
Version: 0.72.1
Release: 1%{?dist}
Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-cartridge-jbossas-7.0.0-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Summary: Provides java-jbossas-7.0.0 support
Group: Development/Languages
Requires: rhc-node
Requires: jboss-as7

%description
Provides jbossas support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}

CARTRIDGE_DIR=$RPM_BUILD_ROOT/usr/libexec/li/cartridges/jbossas-7.0.0
mkdir -p $CARTRIDGE_DIR
cp -r . $CARTRIDGE_DIR
chmod 0750 $CARTRIDGE_DIR/info/hooks/
chmod 0750 $CARTRIDGE_DIR/info/data/
chmod 0750 $CARTRIDGE_DIR/info/build/


%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/jbossas-7.0.0/
