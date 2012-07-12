%global drupal_release      6
%global drupal_base         %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all    %{drupal_base}/sites/all        
%global drupal_modules      %{drupal_sites_all}/modules/features
%global modname             community_wiki

Name:    drupal%{drupal_release}-openshift-features-%{modname}
Version: 1.3.0
Release: 1%{?dist}
Summary: Openshift Red Hat Community Wiki Feature for Drupal6
Group:   Applications/Publishing
License: GPLv2+
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:  drupal6, drupal6-features, drupal6-views, drupal6-votingapi, drupal6-imagefield

%description
Openshift Red Hat Community Wiki Feature for Drupal6


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
* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 1.2.3-1
- 

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 1.2.2-1
- new package built with tito

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 1.2.1-1
- bumping spec versions (admiller@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 1.1.2-1
- Fix all remaining reversion default issues with features
  (ccoleman@redhat.com)
- View revisions permission already exists in user_profile
  (ccoleman@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 1.1.1-1
- bumping spec versions (admiller@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 1.0.4-1
- Added a few more details to the community_wiki drupal feature
  (ffranz@redhat.com)

* Wed Apr 18 2012 Dan McPherson <dmcphers@redhat.com> 1.0.3-1
- Touch all drupal modules to ensure a build. (ccoleman@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 1.0.2-1
- new package built with tito

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> - 1.0.1-1
- update version 

* Thu Apr 5 2012 Clayton Coleman <ccoleman@redhat.com> - 1.0-1
- Initial rpm package
