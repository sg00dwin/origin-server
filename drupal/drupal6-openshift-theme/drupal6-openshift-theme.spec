%global drupal_release      6
%global drupal_base         %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all    %{drupal_base}/sites/all        
%global drupal_themedir     %{drupal_sites_all}/themes
%global drupal_themename    openshift-theme

Name:           drupal6-%{drupal_themename}
Version: 3.4.2
Release:        1%{?dist}
Summary:        Red Hat Openshift theme for Drupal %{drupal_release}

Group:          Applications/Publishing
License:        GPLv2+ and GPL+ or MIT
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       drupal6

%description
Red Hat Openshift Drupal Theme

%prep
%setup -q
# Remove empty index.html and others
find -size 0 | xargs rm -f


%build


%install
rm -rf $RPM_BUILD_ROOT
%{__mkdir} -p $RPM_BUILD_ROOT/%{drupal_themedir}/%{drupal_themename} 
cp -pr . $RPM_BUILD_ROOT/%{drupal_themedir}/%{drupal_themename}


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{drupal_themedir}/%{drupal_themename}


%changelog
* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 3.4.2-1
- new package built with tito

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 3.4.1-1
- bump_minor_versions for sprint 14 (admiller@redhat.com)

* Mon Jun 18 2012 Adam Miller <admiller@redhat.com> 3.3.6-1
- 

* Mon Jun 18 2012 Adam Miller <admiller@redhat.com> 3.3.5-1
- 

* Mon Jun 18 2012 Adam Miller <admiller@redhat.com> 3.3.4-1
- Bug 820861 - Remove broken button from ideas page. (ccoleman@redhat.com)
- Bug 807570 - Improve visual display of Youku videos (ccoleman@redhat.com)

* Thu Jun 14 2012 Adam Miller <admiller@redhat.com> 3.3.3-1
- Add caching to drupal views and blocks for better performance.  Remove
  unnecessary sections from UI (ccoleman@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 3.3.2-1
- incorporate search field within header of site pages, reset headings to use
  line-height instead of margin-bottom, reset /stylesheets/_type.scss to
  bootstrap/_type.scss and merge customizations within so that we only use
  single _type file, minor tinkerings and condensing of styles
  (sgoodwin@redhat.com)
- modifications to search in header within drupal pages (sgoodwin@redhat.com)
- Initial incorporation of search within ui header (sgoodwin@redhat.com)

* Fri Jun 01 2012 Adam Miller <admiller@redhat.com> 3.3.1-1
- bumping spec versions (admiller@redhat.com)

* Fri May 25 2012 Adam Miller <admiller@redhat.com> 3.2.3-1
- Remove comment title permanently (ccoleman@redhat.com)
- css/markup to enable responsive nav for mobile views and lots of fine tuning
  of ui components in both site and console (sgoodwin@redhat.com)

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 3.2.2-1
- community search field fix for ipad/chrome width issue (sgoodwin@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 3.2.1-1
- bumping spec versions (admiller@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 3.1.5-1
- Make forum thread list much simpler (ccoleman@redhat.com)
- Remove extra title attributes from user profile (ccoleman@redhat.com)
- Use article element on blog posts (ccoleman@redhat.com)
- Remove all titles from comments, including those that have escaped HTML
  entities (ccoleman@redhat.com)
- Avoid a warning message on template.php for altering comment form.
  (ccoleman@redhat.com)

* Tue May 08 2012 Adam Miller <admiller@redhat.com> 3.1.4-1
-  minor updates to the visual presentation of the forums threat list and blog
  details views (sgoodwin@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 3.1.3-1
- Add tracking.js to community (ccoleman@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 3.1.2-1
- Add more compact row layout (separators with , will collapse whitespace)
  Update events module to export a new format. (ccoleman@redhat.com)
- Hide comment title if it exists in the comment body (ccoleman@redhat.com)
- Updated requirements from legal regarding removal of opensource disclaimer
  page and changes to language on download page. (ccoleman@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 3.1.1-1
- bumping spec versions (admiller@redhat.com)

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 3.0.11-1
- Automatic commit of package [drupal6-openshift-theme] release [3.0.10-1].
  (admiller@redhat.com)

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 3.0.10-1
- 

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 3.0.9-1
- Bug 815173 - Set header in drupal to force IE edge mode in devenv.   Ensure
  that status messages won't be shown for N-1 compat with site   Update
  copyright colors to be black background   Update copyright date
  (ccoleman@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 3.0.8-1
- Bug 814573 - Fix up lots of links to www.redhat.com/openshift/community
  (ccoleman@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 3.0.7-1
- Automatic commit of package [drupal6-openshift-theme] release [3.0.6-1].
  (admiller@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 3.0.6-1
- Reorder items in user_profile_box to work better with Steve's styling
  (ccoleman@redhat.com)
- Touch up blog theme prior to ship (ccoleman@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 3.0.5-1
- Merge commits dd5326df1f0d5bf05d51aeaae0cc4c457ba45816..ab1d91739634c80b3a9db
  5f468e5ceb277824c7d. Did not merge all of the changes made to core code -
  those are upstream and we can't integrate those directly.
  (ccoleman@redhat.com)
- Drupal updates based on latest changes (ccoleman@redhat.com)
- community comments changes (sgoodwin@redhat.com)
- Simplify link generation to reflect that Drupal can't handle server relative
  menu urls (ccoleman@redhat.com)
- Reformat forum thread and comments (sgoodwin@redhat.com)
- community forum layout changes and remove input box-shadow from console
  (sgoodwin@redhat.com)

* Wed Apr 18 2012 Dan McPherson <dmcphers@redhat.com> 3.0.4-1
- Touch all drupal modules to ensure a build. (ccoleman@redhat.com)

* Wed Apr 18 2012 Adam Miller <admiller@redhat.com> 3.0.3-1
- Bug 813613 (ccoleman@redhat.com)
- Abstract out messaging and handle navbar bottom margin a bit cleaner
  (ccoleman@redhat.com)

* Mon Apr 16 2012 Anderson Silva <ansilva@redhat.com> 3.0.2-1
- new package built with tito

* Tue Apr 16 2012 Anderson Silva <ansilva@redhat.com> - 3.0.1-1
- update version

* Tue Mar 20 2012 Anderson Silva <ansilva@redhat.com> - 3.0-1
- Openshif new theme 

* Wed Mar 14 2012 Anderson Silva <ansilva@redhat.com> - 2.0-2
- Rename RPM for consistency

* Wed Mar 5 2012 Anderson Silva <ansilva@redhat.com> - 2.0-1
- Fix requirements
