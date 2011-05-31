%define cartridgedir %{_libexecdir}/li/cartridges/jbossas-7.0

Summary:   Provides JBossAS7 support
Name:      rhc-cartridge-jbossas-7.0
Version:   0.72.3
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-cartridge-jbossas-7.0-%{version}.tar.gz

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
rm %{buildroot}%{cartridgedir}/jbossas-7.0.spec
rm %{buildroot}%{cartridgedir}/.gitignore

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
* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.3-1
- Update the README with the new brew build task info for jboss-as7 rpm
  (scott.stark@jboss.org)
- Bug 707108 (dmcphers@redhat.com)
- Update the jboss cartridge to use jboss-as7-7.0.0.Beta5OS
  https://brewweb.devel.redhat.com//buildinfo?buildID=165385
  (scott.stark@jboss.org)
- fix issue after refactor with remote clone (dmcphers@redhat.com)
* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- Another cartridge rename to include minor version

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Minor spec cleanup

* Tue May 25 2011 Scott Stark sstark@redhat.com
- change cartridge location to cartridges/jbossas7

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
