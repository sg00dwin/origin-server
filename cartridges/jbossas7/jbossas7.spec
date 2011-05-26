%define cartridgedir %{_libexecdir}/li/cartridges/jbossas7

Summary:   Provides JBossAS7 support
Name:      rhc-cartridge-jbossas7
Version:   0.72.1
Release:   2%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-cartridge-jbossas7-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-node
Requires:  jboss-as7

BuildArch: noarch

%description
Provides JBossAS7 support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
cp -r . %{buildroot}%{cartridgedir}
rm %{buildroot}%{cartridgedir}/.gitignore
rm %{buildroot}%{cartridgedir}/jbossas7.spec

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
%{cartridgedir}/README

%changelog
* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Minor spec cleanup

* Tue May 25 2011 Scott Stark sstark@redhat.com
- change cartridge location to cartridges/jbossas7

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
