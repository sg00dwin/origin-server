%global drupal_release      6
%global drupal_base         %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all    %{drupal_base}/sites/all        
%global drupal_modules      %{drupal_sites_all}/modules/custom
%global modname             redhat_events

Name:    drupal%{drupal_release}-openshift-%{modname}
Version: 1.5.1
Release: 1%{?dist}
Summary: Openshift Red Hat Events Custom Module for Drupal6
Group:   Applications/Publishing
License: GPLv2+
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:  drupal6, drupal6-features, drupal6-views

%description
Summary: Openshift Red Hat Events Custom Module for Drupal6


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
* Sat Nov 17 2012 Adam Miller <admiller@redhat.com> 1.5.1-1
- bump_minor_versions for sprint 21 (admiller@redhat.com)

* Tue Nov 13 2012 Adam Miller <admiller@redhat.com> 1.4.2-1
- Fixes BZ875635, reordered events fields (ffranz@redhat.com)
- Fixes BZ875616 (link to internal events in the events calendar view)
  (ffranz@redhat.com)
- Updated Events Drupal Feature (sync permissions, new fields, etc)
  (ffranz@redhat.com)
- Styled the events list by country, sync date and country views, ical feed
  improvements (ffranz@redhat.com)
- Improved styling for events list (ffranz@redhat.com)
- Added more data to the iCal feed, added iCal link, improved tabs styling in
  the events list page (ffranz@redhat.com)
- Events ICS/ICAL feed (ffranz@redhat.com)
- Events RSS feed (ffranz@redhat.com)
- New Events section styles, added event detail page (ffranz@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 1.4.1-1
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 1.3.2-1
- new package built with tito

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 1.3.1-1
- bump_minor_versions for sprint 14 (admiller@redhat.com)

* Thu Jun 14 2012 Adam Miller <admiller@redhat.com> 1.2.2-1
- Add caching to drupal views and blocks for better performance.  Remove
  unnecessary sections from UI (ccoleman@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 1.2.1-1
- bumping spec versions (admiller@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 1.1.3-1
- Make the dates in the event view show proper From: To: behavior
  (ccoleman@redhat.com)
- Add drupal css classes to two views (ccoleman@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 1.1.2-1
- Merge events recent changes and user profile into code. (ccoleman@redhat.com)
- Add more compact row layout (separators with , will collapse whitespace)
  Update events module to export a new format. (ccoleman@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 1.1.1-1
- bumping spec versions (admiller@redhat.com)
- Use nav-pills for the event navigation (ccoleman@redhat.com)
- Update enable-modules.sh (ccoleman@redhat.com)

* Wed Apr 18 2012 Dan McPherson <dmcphers@redhat.com> 1.0.3-1
- Touch all drupal modules to ensure a build. (ccoleman@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 1.0.2-1
- new package built with tito

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> - 1.0.1-1
- update version

* Mon Mar 5 2012 Anderson Silva <ansilva@redhat.com> - 1.0-1
- Initial rpm package
