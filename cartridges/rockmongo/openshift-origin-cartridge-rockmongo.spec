%global cartridgedir %{_libexecdir}/openshift/cartridges/rockmongo

Summary:   Embedded RockMongo support
Name:      openshift-origin-cartridge-rockmongo
Version: 0.6.2
Release:   1%{?dist}
Group:     Applications/Internet
License:   ASL 2.0 and NBSD
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Requires:  openshift-origin-cartridge-mongodb
Requires:  rubygem(openshift-origin-node)
Requires:  openshift-origin-node-util

Obsoletes: openshift-origin-cartridge-rockmongo-1.1

%description
Provides RockMongo V2 cartridge support

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

%files
%defattr(-,root,root,-)
%dir %{cartridgedir}
%attr(0755,-,-) %{cartridgedir}/bin/
%{cartridgedir}
%doc %{cartridgedir}/COPYRIGHT
%doc %{cartridgedir}/LICENSE
%doc %{cartridgedir}/README.md

%changelog
* Tue Aug 20 2013 Adam Miller <admiller@redhat.com> 0.6.2-1
- Bug 968280 - Ensure Stopping/Starting messages during git push
  (jhonce@redhat.com)

* Thu Aug 08 2013 Adam Miller <admiller@redhat.com> 0.6.1-1
- Merge pull request #1793 from jwhonce/bug/985514
  (dmcphers+openshiftbot@redhat.com)
- Bug 985514 - Update CartridgeRepository when mcollectived restarted
  (jhonce@redhat.com)
- bump_minor_versions for sprint 32 (admiller@redhat.com)

* Wed Jul 31 2013 Adam Miller <admiller@redhat.com> 0.5.5-1
- Update cartridge versions for Sprint 31 (jhonce@redhat.com)

* Wed Jul 31 2013 Adam Miller <admiller@redhat.com> 0.5.4-1
- Fail gracefully if mongodb cartridge is absent (asari.ruby@gmail.com)
- Bug 989863 (asari.ruby@gmail.com)

* Mon Jul 29 2013 Adam Miller <admiller@redhat.com> 0.5.3-1
- Bug 982738 (dmcphers@redhat.com)

* Wed Jul 24 2013 Adam Miller <admiller@redhat.com> 0.5.2-1
- Remove mongodb install check from rock-mongo bin/install. Now, its done by
  broker during configure order. (rpenta@redhat.com)

* Fri Jul 12 2013 Adam Miller <admiller@redhat.com> 0.5.1-1
- bump_minor_versions for sprint 31 (admiller@redhat.com)

* Tue Jul 02 2013 Adam Miller <admiller@redhat.com> 0.4.2-1
- Bug 976921: Move cart installation to %%posttrans (ironcladlou@gmail.com)
- remove v2 folder from cart install (dmcphers@redhat.com)

* Tue Jun 25 2013 Adam Miller <admiller@redhat.com> 0.4.1-1
- bump_minor_versions for sprint 30 (admiller@redhat.com)

* Mon Jun 17 2013 Adam Miller <admiller@redhat.com> 0.3.2-1
- First pass at removing v1 cartridges (dmcphers@redhat.com)
- Fix bug 969930 (pmorie@gmail.com)
- Fix httpd stop for httpd-based carts. (mrunalp@gmail.com)

* Thu May 30 2013 Adam Miller <admiller@redhat.com> 0.3.1-1
- bump_minor_versions for sprint 29 (admiller@redhat.com)

* Fri May 24 2013 Adam Miller <admiller@redhat.com> 0.2.4-1
- remove install build required for non buildable carts (dmcphers@redhat.com)

* Wed May 22 2013 Adam Miller <admiller@redhat.com> 0.2.3-1
- Bug 962662 (dmcphers@redhat.com)
- Bug 965537 - Dynamically build PassEnv httpd configuration
  (jhonce@redhat.com)
- Bug 965476 - control#status returned non-zero if httpd was down
  (jhonce@redhat.com)

* Thu May 16 2013 Adam Miller <admiller@redhat.com> 0.2.2-1
- locking fixes and adjustments (dmcphers@redhat.com)
- Merge pull request #1367 from fotioslindiakos/locked_files
  (dmcphers+openshiftbot@redhat.com)
- WIP Cartridge Refactor -- Cleanup spec files (jhonce@redhat.com)
- Added erb processing to managed_files.yml (fotios@redhat.com)
- Card online_runtime_297 - Allow cartridges to use more resources
  (jhonce@redhat.com)
- Card online_runtime_297 - Allow cartridges to use more resources
  (jhonce@redhat.com)
- Card online_runtime_272 - RockMongo migration (jhonce@redhat.com)

* Wed May 08 2013 Adam Miller <admiller@redhat.com> 0.2.1-1
- bump_minor_versions for sprint 28 (admiller@redhat.com)

* Fri May 03 2013 Adam Miller <admiller@redhat.com> 0.1.2-1
- Converted metadata/{locked_files,snapshot*}.txt (fotios@redhat.com)

* Thu Apr 25 2013 Adam Miller <admiller@redhat.com> 0.1.1-1
- Split v2 configure into configure/post-configure (ironcladlou@gmail.com)
- implementing install and post-install (dmcphers@redhat.com)
- Bug 954110 - Share RockMongo source across gear instances (jhonce@redhat.com)
- bump_minor_versions for sprint XX (tdawson@redhat.com)

* Mon Apr 15 2013 Adam Miller <admiller@redhat.com> 0.0.7-1
- WIP Cartridge Refactor - Scrub manifests (jhonce@redhat.com)

* Wed Apr 10 2013 Adam Miller <admiller@redhat.com> 0.0.6-1
- WIP Cartridge Refactor - Fix ERB env variables (jhonce@redhat.com)

* Tue Apr 09 2013 Adam Miller <admiller@redhat.com> 0.0.5-1
- message improvement (dmcphers@redhat.com)

* Mon Apr 08 2013 Dan McPherson <dmcphers@redhat.com> 0.0.4-1
- new package built with tito

* Mon Apr 08 2013 Jhon Honce <jhonce@redhat.com> 0.0.3-1
- WIP Cartridge Refactor - RockMongo cartridge (jhonce@redhat.com)
- Automatic commit of package [openshift-origin-cartridge-rockmongo] release
  [0.0.2-1]. (jhonce@redhat.com)
- WIP Cartridge Refactor - RockMongo cartridge (jhonce@redhat.com)

* Thu Apr 04 2013 Jhon Honce <jhonce@redhat.com> 0.0.2-1
- new package built with tito


