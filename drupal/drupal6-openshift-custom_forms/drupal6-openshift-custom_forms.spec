%global drupal_release      6
%global drupal_base         %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all    %{drupal_base}/sites/all        
%global drupal_modules      %{drupal_sites_all}/modules/custom
%global modname             custom_forms

Name:    drupal%{drupal_release}-openshift-%{modname}
Version: 0.11.2
Release: 1%{?dist}
Summary: Openshift Red Hat Custom Forms for Drupal6
Group:   Applications/Publishing
License: GPLv2+
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:  drupal6

%description
Summary: Openshift Red Hat Custom Forms for Drupal6


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
* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.11.2-1
- new package built with tito

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.11.1-1
- fix up spec versions (dmcphers@redhat.com)
- bumping spec versions (admiller@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 1.3.1-1
- bumping spec versions (admiller@redhat.com)

* Wed Apr 18 2012 Dan McPherson <dmcphers@redhat.com> 1.2.5-1
- Touch all drupal modules to ensure a build. (ccoleman@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 1.2.4-1
- drupal6-openshift-custom_forms: fix typo Source0 (ansilva@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 1.2.3-1
- drupal6-openshift-custom_forms: fix Source0 for tito (ansilva@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 1.2.2-1
- drupal6-openshift-custom_forms: fix %%prep for tito release
  (ansilva@redhat.com)
- drupal: changing layout of source code for proper tito rpm
  (ansilva@redhat.com)
- update version to 1.2.1 (ansilva@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 1.2.1-1
- update version 

* Mon Apr 16 2012 Dan McPherson <dmcphers@redhat.com> 1.2-1
- new package built with tito

* Mon Mar 5 2012 Anderson Silva <ansilva@redhat.com> - 1.0-1
- Initial rpm package
