%define cartridgedir %{_libexecdir}/li/cartridges/php-5.3

Summary:   Provides php-5.3 support
Name:      rhc-cartridge-php-5.3
Version:   0.72.1
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-cartridge-php5-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-node
Requires:  php >= 5.3.2
Requires:  php < 5.4.0
Requires:  mod_bw
Requires:  rubygem-builder
Requires:  php-pdo
Requires:  php-gd
Requires:  php-xml
Requires:  php-mysql
Requires:  php-pgsql

BuildArch: noarch

%description
Provides php support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
cp -r . %{buildroot}%{cartridgedir}
rm %{buildroot}%{cartridgedir}/php5.spec

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
