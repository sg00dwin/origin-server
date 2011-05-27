%define cartridgedir %{_libexecdir}/li/cartridges/rack-1.1

Summary:   Provides ruby rack support running on Phusion Passenger
Name:      rhc-cartridge-rack-1.1
Version:   0.72.1
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-cartridge-rack-1.1-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-node
Requires:  mod_bw
Requires:  rubygems
Requires:  rubygem-rack >= 1.1.0
#Requires:  rubygem-rack < 1.2.0
Requires:  rubygem-passenger
Requires:  rubygem-passenger-native
Requires:  rubygem-passenger-native-libs
Requires:  mod_passenger
Requires:  rubygem-bundler
Requires:  rubygem-sqlite3
Requires:  ruby-sqlite3
Requires:  ruby-mysql
Requires:  ruby-nokogiri

# Deps for users
Requires: ruby-RMagick

BuildArch: noarch

%description
Provides rack support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
cp -r . %{buildroot}%{cartridgedir}
rm %{buildroot}%{cartridgedir}/rack-1.1.spec

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/data/
%attr(0750,-,-) %{cartridgedir}/info/build/
%{cartridgedir}/info/configuration/
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
