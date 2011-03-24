%{!?ruby_sitelibdir: %global ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

Name: li-tests
Version: 0.1
Release: 1%{?dist}
Summary: Libra automated tests

Group: Development/Libraries
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: li-tests-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: x86_64

BuildRequires: rubygem-rake
Requires: ruby >= 1.8.7
Requires: rubygem-cucumber
Requires: rubygem-json
Requires: rubygem-parseconfig
Requires: rubygem-rake
Requires: rubygem-rspec

%description
Provides Libra automated tests

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
rake DESTDIR="$RPM_BUILD_ROOT" install:tests

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/root/tests

%changelog
* Thu Mar 24 2011 Matt Hicks <mhicks@redhat.com> 0.1-1
- Packaging up tests
