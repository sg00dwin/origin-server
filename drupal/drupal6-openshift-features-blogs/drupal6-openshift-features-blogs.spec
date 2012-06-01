%global drupal_release      6
%global drupal_base         %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all    %{drupal_base}/sites/all        
%global drupal_modules      %{drupal_sites_all}/modules/features
%global modname             blogs

Name:    drupal%{drupal_release}-openshift-features-%{modname}
Version: 1.3.0
Release: 1%{?dist}
Summary: Openshift Red Hat Custom Blog Feature for Drupal6
Group:   Applications/Publishing
License: GPLv2+
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:  drupal6, drupal6-features, drupal6-views, drupal6-votingapi, drupal6-imagefield

%description
Openshift Red Hat Custom Blog Feature for Drupal6


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
* Thu May 24 2012 Adam Miller <admiller@redhat.com> 1.2.4-1
- Bug 822391 - Remove author from full view of blogs (ccoleman@redhat.com)

* Tue May 22 2012 Dan McPherson <dmcphers@redhat.com> 1.2.3-1
- Automatic commit of package [drupal6-openshift-features-blogs] release
  [1.2.2-1]. (admiller@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 1.2.2-1
- 

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 1.2.1-1
- bumping spec versions (admiller@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 1.1.3-1
- Fix all remaining reversion default issues with features
  (ccoleman@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 1.1.2-1
- Automatic commit of package [drupal6-openshift-features-blogs] release
  [1.1.1-1]. (admiller@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 1.1.1-1
- bumping spec versions (admiller@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 1.0.7-1
- Bug 814573 - Fix up lots of links to www.redhat.com/openshift/community
  (ccoleman@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 1.0.6-1
- Touch up blog theme prior to ship (ccoleman@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 1.0.5-1
- Merge commits dd5326df1f0d5bf05d51aeaae0cc4c457ba45816..ab1d91739634c80b3a9db
  5f468e5ceb277824c7d. Did not merge all of the changes made to core code -
  those are upstream and we can't integrate those directly.
  (ccoleman@redhat.com)

* Wed Apr 18 2012 Dan McPherson <dmcphers@redhat.com> 1.0.4-1
- Touch all drupal modules to ensure a build. (ccoleman@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 1.0.3-1
- drupal6-openshift-features-blogs: fix Source0 (ansilva@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 1.0.2-1
- new package built with tito

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> - 1.0.1-1
- update version 

* Mon Mar 5 2012 Anderson Silva <ansilva@redhat.com> - 1.0-1
- Initial rpm package
