%define cartridgedir %{_libexecdir}/li/cartridges/jenkins-1.4

Summary:   Provides jenkins-1.4 support
Name:      rhc-cartridge-jenkins-1.4
Version:   0.78.6
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: git
Requires:  rhc-node
Requires:  jenkins

BuildArch: noarch

%description
Provides jenkins cartridge to openshift nodes

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
cp -r info %{buildroot}%{cartridgedir}/
cp -r template %{buildroot}%{cartridgedir}/
mkdir -p %{buildroot}%{cartridgedir}/info/data/

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/data/
%attr(0750,-,-) %{cartridgedir}/info/build/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%{cartridgedir}/template/
%config(noreplace) %{cartridgedir}/info/configuration/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Thu Sep 22 2011 Dan McPherson <dmcphers@redhat.com> 0.78.6-1
- perm changes on jenkins_id_rsa and allow user_info calls from broker auth key
  (dmcphers@redhat.com)

* Tue Sep 20 2011 Dan McPherson <dmcphers@redhat.com> 0.78.5-1
- add broker auth key when jenkins is created (dmcphers@redhat.com)
- add base jenkins template (dmcphers@redhat.com)
- call add and remove ssh keys from jenkins configure and deconfigure
  (dmcphers@redhat.com)

* Mon Sep 19 2011 Dan McPherson <dmcphers@redhat.com> 0.78.4-1
- jenkins cleanup (dmcphers@redhat.com)

* Thu Sep 15 2011 Dan McPherson <dmcphers@redhat.com> 0.78.3-1
- updated mcs_level generation for app accounts > 522 (markllama@redhat.com)

* Wed Sep 14 2011 Dan McPherson <dmcphers@redhat.com> 0.78.2-1
- fixing cached field (mmcgrath@redhat.com)
- Changing default path to be at the end so we can overwrite system utilities
  (mmcgrath@redhat.com)
- Adding new top (mmcgrath@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.78.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Aug 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.77.4-1
- removed php reference (mmcgrath@redhat.com)

* Mon Aug 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.77.3-1
- new package built with tito

