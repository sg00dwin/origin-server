%global drupal_release      6
%global drupal_base         %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all    %{drupal_base}/sites/all        
%global drupal_modules      %{drupal_sites_all}/modules/features
%global modname             application_quickstarts

Name:    drupal%{drupal_release}-openshift-features-%{modname}
Version: 1.2.0
Release: 1%{?dist}
Summary: Openshift Application Quickstarts Feature for Drupal6
Group:   Applications/Publishing
License: GPLv2+
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:  drupal6, drupal6-features, drupal6-views, drupal6-votingapi, drupal6-views_datasource

%description
Openshift Application Quickstarts Feature for Drupal6.  Provides a
content type for creating and managing precanned application
definitions.


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
* Fri Dec 07 2012 Adam Miller <admiller@redhat.com> 1.1.3-1
- Sitemap and updates to application quickstarts (ccoleman@redhat.com)

* Wed Dec 05 2012 Adam Miller <admiller@redhat.com> 1.1.2-1
- Bug 882784 - Unable to search quickstart (ccoleman@redhat.com)

* Sat Nov 17 2012 Adam Miller <admiller@redhat.com> 1.1.1-1
- bump_minor_versions for sprint 21 (admiller@redhat.com)

* Fri Nov 16 2012 Adam Miller <admiller@redhat.com> 1.0.2-1
- Bug 877222 - Help example for quickstarts is wrong and confusing
  (ccoleman@redhat.com)

* Tue Nov 13 2012 Clayton Coleman <ccoleman@redhat.com> 1.0.1-1
- new package built with tito

