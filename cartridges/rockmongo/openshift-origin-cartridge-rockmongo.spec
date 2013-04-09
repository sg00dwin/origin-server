%global cartridgedir %{_libexecdir}/openshift/cartridges/v2/rockmongo

Summary:   Embedded RockMongo support
Name:      openshift-origin-cartridge-rockmongo
Version:   0.0.4
Release:   1%{?dist}
Group:     Applications/Internet
License:   ASL 2.0
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Requires:  openshift-origin-cartridge-mongodb
Requires:  rubygem(openshift-origin-node)

%description
Provides RockMongo V2 cartridge support

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/openshift/cartridges/v2
cp -r * %{buildroot}%{cartridgedir}/

%post

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%dir %{cartridgedir}/env
%dir %{cartridgedir}/etc
%dir %{cartridgedir}/html
%dir %{cartridgedir}/logs
%dir %{cartridgedir}/metadata
%dir %{cartridgedir}/run
%dir %{cartridgedir}/sessions
%attr(0755,-,-) %{cartridgedir}/bin/
%attr(0755,-,-) %{cartridgedir}
%{cartridgedir}/metadata/manifest.yml
%doc %{cartridgedir}/COPYRIGHT
%doc %{cartridgedir}/LICENSE
%doc %{cartridgedir}/changelog
%doc %{cartridgedir}/README.md

%changelog
* Mon Apr 08 2013 Dan McPherson <dmcphers@redhat.com> 0.0.4-1
- new package built with tito

* Mon Apr 08 2013 Jhon Honce <jhonce@redhat.com> 0.0.3-1
- WIP Cartridge Refactor - RockMongo cartridge (jhonce@redhat.com)
- Automatic commit of package [openshift-origin-cartridge-rockmongo] release
  [0.0.2-1]. (jhonce@redhat.com)
- WIP Cartridge Refactor - RockMongo cartridge (jhonce@redhat.com)

* Thu Apr 04 2013 Jhon Honce <jhonce@redhat.com> 0.0.2-1
- new package built with tito


