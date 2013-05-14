%define cartridgedir %{_libexecdir}/openshift/cartridges/v2/metrics

Name: openshift-origin-cartridge-metrics
Version: 1.9.1
Release: 1%{?dist}
Summary: Metrics cartridge

Group: Applications/Internet
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires:      rubygem(openshift-origin-node)
Requires:      openshift-origin-node-util

%description
Provides metrics cartridge support

%prep
%setup -q


%build
%__rm %{name}.spec


%install
%__rm -rf %{buildroot}
%__mkdir -p %{buildroot}%{cartridgedir}
%__cp -r * %{buildroot}%{cartridgedir}

%clean
%__rm -rf %{buildroot}

%post
%{_sbindir}/oo-admin-cartridge --action install --source %{cartridgedir}

%files
%defattr(-,root,root,-)
%dir %{cartridgedir}
%attr(0755,-,-) %{cartridgedir}/bin/
%attr(0755,-,-) %{cartridgedir}
%doc %{cartridgedir}/README.md
%doc %{cartridgedir}/COPYRIGHT
%doc %{cartridgedir}/LICENSE

%changelog
* Wed May 08 2013 Adam Miller <admiller@redhat.com> 1.9.1-1
- bump_minor_versions for sprint 28 (admiller@redhat.com)

* Fri May 03 2013 Adam Miller <admiller@redhat.com> 1.8.3-1
- Converted metadata/{locked_files,snapshot*}.txt (fotios@redhat.com)

* Mon Apr 29 2013 Adam Miller <admiller@redhat.com> 1.8.2-1
- Bug 957073 (dmcphers@redhat.com)

* Thu Apr 25 2013 Adam Miller <admiller@redhat.com> 1.8.1-1
- Split v2 configure into configure/post-configure (ironcladlou@gmail.com)
- more install and post-install (dmcphers@redhat.com)
- bump_minor_versions for sprint XX (tdawson@redhat.com)

* Mon Apr 15 2013 Adam Miller <admiller@redhat.com> 1.7.9-1
- Merge pull request #1183 from jwhonce/wip/manifest_scrub
  (dmcphers+openshiftbot@redhat.com)
- cleanup (dmcphers@redhat.com)
- WIP Cartridge Refactor - Scrub manifests (jhonce@redhat.com)
- cleanup (dmcphers@redhat.com)

* Fri Apr 12 2013 Adam Miller <admiller@redhat.com> 1.7.8-1
- fix typo (dmcphers@redhat.com)

* Thu Apr 11 2013 Adam Miller <admiller@redhat.com> 1.7.7-1
- Locked files fix for metrics (ironcladlou@gmail.com)

* Mon Apr 08 2013 Dan McPherson <dmcphers@redhat.com> 1.7.6-1
- Merge pull request #1132 from ironcladlou/dev/v2carts/vendor-changes
  (dmcphers+openshiftbot@redhat.com)
- Remove vendor name from installed V2 cartridge path (ironcladlou@gmail.com)

* Mon Apr 08 2013 Adam Miller <admiller@redhat.com> 1.7.5-1
- metrics WIP (dmcphers@redhat.com)
- Refactor v2 cartridge SDK location and accessibility (ironcladlou@gmail.com)
- metrics WIP (dmcphers@redhat.com)

* Tue Apr 02 2013 Dan McPherson <dmcphers@redhat.com> 1.7.4-1
- new package built with tito

* Tue Apr 02 2013 Dan McPherson <dmcphers@redhat.com> 1.7.3-1
- Automatic commit of package [openshift-origin-cartridge-metrics] release
  [1.7.2-1]. (dmcphers@redhat.com)

* Tue Apr 02 2013 Dan McPherson <dmcphers@redhat.com> 1.7.2-1
- new package built with tito

* Thu Mar 28 2013 Adam Miller <admiller@redhat.com> 1.7.1-1
- bump_minor_versions for sprint 26 (admiller@redhat.com)