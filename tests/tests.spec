Name: rhc-tests
Version: 0.70.2
Release: 1%{?dist}
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-tests-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Summary: Dependencies for OpenShift tests
Group: Development/Libraries
Requires: rhc-devenv

%description
Provides the OpenShift tests

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
TEST_DIR=$RPM_BUILD_ROOT/root
mkdir -p $TEST_DIR
cp -r . $TEST_DIR

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/root