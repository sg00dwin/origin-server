%global drupal_release 6
%global drupal_base %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all %{drupal_base}/sites/all
%global drupal_modules %{drupal_sites_all}/modules/custom
%global modname partner_program

Name: drupal%{drupal_release}-openshift-%{modname}
Version: 0.3.3
Release: 1%{?dist}
Summary: OpenShift Partner Program Drupal Content
Group: Applications/Publishing
License: GPLv2+
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: drupal6

%description
Openshift Online Partner Program Module


%prep
%setup -q
# Remove empty index.html and others
find -size 0 | xargs rm -f

%build


%install
rm -rf $RPM_BUILD_ROOT
%{__mkdir} -p $RPM_BUILD_ROOT/%{drupal_modules}/%{modname}
cp -pr . $RPM_BUILD_ROOT/%{drupal_modules}/%{modname}


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{drupal_modules}/%{modname}

%changelog
* Wed Aug 21 2013 Adam Miller <admiller@redhat.com> 0.3.3-1
- Partner portal company logo upload failing (jforrest@redhat.com)

* Fri Aug 16 2013 Adam Miller <admiller@redhat.com> 0.3.2-1
- Partner portal edge case email missing user name - review comments
  (jforrest@redhat.com)
- Partner portal edge case email missing user name (jforrest@redhat.com)
- Partner portal apply info email fix - phase2 bitbucket commit
  bb93e0778153f6d3d9df02bfb4cd9a6b3c8af298 (jforrest@redhat.com)

* Thu Aug 08 2013 Adam Miller <admiller@redhat.com> 0.3.1-1
- bump_minor_versions for sprint 32 (admiller@redhat.com)

* Tue Jul 30 2013 Adam Miller <admiller@redhat.com> 0.2.2-1
- Partner portal fixes - review comments (jforrest@redhat.com)
- Partner portal fixes - refix typo (jforrest@redhat.com)
- Partner portal fixes - final cleanup (jforrest@redhat.com)
- Partner portal fixes phase2 bitbucket commit
  8a91b20d713f7621c794d81506835439ba253dbd (jforrest@redhat.com)
- Partner portal fixes phase2 bitbucket commit
  bf7f530ae7c81893ffa7cbec6abd00511b41d8e1 (jforrest@redhat.com)
- Partner portal bug fixes - phase2 bitbucket commit
  9352136c8798fa750ea6d1110ff8577df31cb0ed (jforrest@redhat.com)

* Fri Jul 12 2013 Adam Miller <admiller@redhat.com> 0.2.1-1
- bump_minor_versions for sprint 31 (admiller@redhat.com)

* Wed Jul 10 2013 Adam Miller <admiller@redhat.com> 0.1.2-1
- phase2 partner portal bug fix - bitbucket commit
  1e3f30ae746632e61e69266012dc388227ac4eef (jforrest@redhat.com)
- Fix admin user view to use the partner admin role id in PROD
  (jforrest@redhat.com)
- Fixes to the partner portal (jforrest@redhat.com)
- Partner portal phase2 bitbucket commit
  219d48b380922510669af33d95547638cef4e071 (jforrest@redhat.com)

* Tue Jun 25 2013 Adam Miller <admiller@redhat.com> 0.1.1-1
- bump_minor_versions for sprint 30 (admiller@redhat.com)

* Fri Jun 07 2013 Adam Miller 0.0.3-4
- Bump spec for mass drupal rebuild

* Thu Jun 06 2013 Adam Miller 0.0.3-3
- Bump spec for mass drupal rebuild

* Wed Jun 05 2013 Adam Miller 0.0.3-2
- Bump spec for mass drupal rebuild

* Tue Jun 04 2013 Adam Miller <admiller@redhat.com> 0.0.3-1
- new package built with tito

* Tue Jun 04 2013 Adam Miller - 0.0.1-1
- First package for Drupal Partner Program Content
