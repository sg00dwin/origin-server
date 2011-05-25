%{!?ruby_sitelibdir: %global ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}

Name: rhc-server-common
Version: 0.70.2
Release: 1%{?dist}
Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-server-common-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Summary: Common dependencies of the OpenShift broker and site
Requires: ruby >= 1.8.7
Requires: rubygem-parseconfig
Requires: rubygem-json

%description
Provides the common dependencies for the OpenShift broker and site

%prep
%setup -q


%build
for f in lib/**/*.rb
do
  ruby -c $f
done

%install
rm -rf $RPM_BUILD_ROOT
SITE_LIB_DIR=$RPM_BUILD_ROOT/%{ruby_sitelibdir}/openshift
mkdir -p $SITE_LIB_DIR
cp -r lib/* $SITE_LIB_DIR


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{ruby_sitelibdir}/openshift
