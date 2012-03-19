%define cartdir %{_libexecdir}/stickshift/cartridges

Summary:   StickShift common cartridge components
Name:      stickshift-abstract
Version:   0.7.1
Release:   1%{?dist}
Group:     Network/Daemons
License:   ASL 2.0
URL:       http://openshift.redhat.com
Source0:   stickshift-abstract-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildArch: noarch

%description
This contains the common function used while building cartridges.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartdir}
cp -rv abstract %{buildroot}%{cartdir}/
cp -rv abstract-httpd %{buildroot}%{cartdir}/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%dir %attr(0755,root,root) %{_libexecdir}/stickshift/cartridges/abstract-httpd/
%attr(0750,-,-) %{_libexecdir}/stickshift/cartridges/abstract-httpd/info/hooks/
%attr(0755,-,-) %{_libexecdir}/stickshift/cartridges/abstract-httpd/info/bin/
#%{_libexecdir}/stickshift/cartridges/abstract-httpd/info
%dir %attr(0755,root,root) %{_libexecdir}/stickshift/cartridges/abstract/
%attr(0750,-,-) %{_libexecdir}/stickshift/cartridges/abstract/info/hooks/
%attr(0755,-,-) %{_libexecdir}/stickshift/cartridges/abstract/info/bin/
%attr(0755,-,-) %{_libexecdir}/stickshift/cartridges/abstract/info/lib/
%attr(0750,-,-) %{_libexecdir}/stickshift/cartridges/abstract/info/connection-hooks/
%{_libexecdir}/stickshift/cartridges/abstract/info

%post

%changelog
* Sat Mar 17 2012 Dan McPherson <dmcphers@redhat.com> 0.7.1-1
- bump spec numbers (dmcphers@redhat.com)
- USER_APP_NAME -> APP_NAME (dmcphers@redhat.com)

* Thu Mar 15 2012 Dan McPherson <dmcphers@redhat.com> 0.6.9-1
- Character swap in a function name. (rmillner@redhat.com)
- The legacy APP env files were fine for bash but we have a number of parsers
  which could not handle the new format.  Move legacy variables to the app_ctl
  scripts and have migration set the TRANSLATE_GEAR_VARS variable to include
  pairs of variables to migrate. (rmillner@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.6.8-1
- Rename libra-proxy to stickshift-proxy (rmillner@redhat.com)
- dont set status multiple times (dmcphers@redhat.com)

* Tue Mar 13 2012 Dan McPherson <dmcphers@redhat.com> 0.6.7-1
- changing libra to stickshift in logger tag (abhgupta@redhat.com)

* Mon Mar 12 2012 Dan McPherson <dmcphers@redhat.com> 0.6.6-1
- cart_dir is now cartridge_base_path (rchopra@redhat.com)

* Sat Mar 10 2012 Dan McPherson <dmcphers@redhat.com> 0.6.5-1
- Fix issues stickshift merge missed. (ramr@redhat.com)
- Fixes to get ss-connector-execute working after 'ss' merge. (ramr@redhat.com)

* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.6.4-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Mar 09 2012 Krishna Raman <kraman@gmail.com> 0.6.1-1
- New package for StickShift (was Cloud-Sdk)

* Thu Mar 08 2012 Krishna Raman <kraman@gmail.com> 0.6.1-1
- Creating StickShift abstract package

