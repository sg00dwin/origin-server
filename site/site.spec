%define htmldir %{_localstatedir}/www/html
%define sitedir %{_localstatedir}/www/libra/site

Summary:   Li site components
Name:      rhc-site
Version:   0.75.16
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-site-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-common
Requires:  rhc-server-common
Requires:  httpd
Requires:  mod_ssl
Requires:  mod_passenger
Requires:  rubygem-passenger-native-libs
Requires:  rubygem-rails
Requires:  rubygem-json
Requires:  rubygem-parseconfig
Requires:  rubygem-aws
Requires:  rubygem-xml-simple
Requires:  rubygem-formtastic
Requires:  rubygem-haml
Requires:  rubygem-recaptcha

Obsoletes: rhc-server

BuildArch: noarch

%description
This contains the OpenShift website which manages user authentication,
authorization and also the workflows to request access.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{sitedir}
cp -r . %{buildroot}%{sitedir}
ln -s %{sitedir}/public %{buildroot}%{htmldir}/app

mkdir -p %{buildroot}%{sitedir}/run
mkdir -p %{buildroot}%{sitedir}/log
touch %{buildroot}%{sitedir}/log/production.log

%clean
rm -rf %{buildroot}                                

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,root,libra_user) %{sitedir}/log/production.log
%config(noreplace) %{sitedir}/config/environments/production.rb
%{sitedir}
%{htmldir}/app

%post
/bin/touch %{sitedir}/log/production.log

%changelog
* Thu Aug 04 2011 Dan McPherson <dmcphers@redhat.com> 0.75.16-1
- 

* Thu Aug 04 2011 Dan McPherson <dmcphers@redhat.com> 0.75.15-1
- switch express api to localhost (dmcphers@redhat.com)
- Update express api tests to comply with new express api functionality
  (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Button styling tweaks (edirsh@redhat.com)
- Handling nil referrers (mhicks@redhat.com)
- Improvements to flash message styling (edirsh@redhat.com)
- Home page content tweaks (edirsh@redhat.com)
- Show getting started button on home page if user is logged in
  (edirsh@redhat.com)
- Bug 728125 (edirsh@redhat.com)
- Updated omniture code to use correct account information in link tracking
  function (edirsh@redhat.com)
- fix production.rb back to prod state (dmcphers@redhat.com)

* Thu Aug 04 2011 Dan McPherson <dmcphers@redhat.com> 0.75.14-1
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Bug 728129 (edirsh@redhat.com)
- Bug 728140 (edirsh@redhat.com)
- bug 728126 (dmcphers@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Added openshift twitter avatar back in (edirsh@redhat.com)

* Wed Aug 03 2011 Dan McPherson <dmcphers@redhat.com> 0.75.13-1
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Cleaned out unnecessary resource files (edirsh@redhat.com)
- another ie video fix (dmcphers@redhat.com)
- fix videos on IE (dmcphers@redhat.com)
- fix twitter @ links (dmcphers@redhat.com)

* Wed Aug 03 2011 Dan McPherson <dmcphers@redhat.com> 0.75.12-1
- adding generated css (dmcphers@redhat.com)
- IE fixes (dmcphers@redhat.com)
- Remove insecure content from flex page so no more scary warnings
  (edirsh@redhat.com)
- Make more html5 elements render as block-level by default for older browsers
  (edirsh@redhat.com)
- Change the product pages to display 'sign up' link instead of confusing
  account menu when logged out. (edirsh@redhat.com)
- Make header block-level element in older browsers (edirsh@redhat.com)
- Bug 727724 (edirsh@redhat.com)
- Remove cloud bg due to readability issues (edirsh@redhat.com)
- Bug 727729 (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Converted some relative measures to absolute to improve homepage rendering
  stability (edirsh@redhat.com)
- link to product specific login pages when possible (dmcphers@redhat.com)
- Omniture plugin code corrections (edirsh@redhat.com)
- Improved whitespace on home page (edirsh@redhat.com)
- Home page copy updated (edirsh@redhat.com)
- Fixed domain validation to not run if namespace is nil (edirsh@redhat.com)

* Tue Aug 02 2011 Dan McPherson <dmcphers@redhat.com> 0.75.11-1
- Form error message styling improvements (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Bug 727418 (edirsh@redhat.com)
- IE fixes (dmcphers@redhat.com)
- Corrected favicon and apple touch icon images (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Omniture link and campaign tracking fixes (edirsh@redhat.com)
- ie fixes (dmcphers@redhat.com)
- Bug 727427 (edirsh@redhat.com)
- Removed unnecessary ruby call in view (edirsh@redhat.com)
- Bug 727454 (edirsh@redhat.com)
- Tweaked styles to improve rendering in less-capable browsers
  (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Corrected account reference in omniture link tracking function
  (edirsh@redhat.com)
- Bug 727421 (dmcphers@redhat.com)
- Bug 727432 (dmcphers@redhat.com)

* Mon Aug 01 2011 Dan McPherson <dmcphers@redhat.com> 0.75.10-1
- fix syntax error (dmcphers@redhat.com)
- Button styling tweak (edirsh@redhat.com)
- Changed announcements to actual announcements (edirsh@redhat.com)
- Changed submit button class for styling purposes on access forms
  (edirsh@redhat.com)
- Change 'go to flex' link to point to flex_redirect path (edirsh@redhat.com)
- Fixed javascript reference in access pages (edirsh@redhat.com)
- Fixed javascript reference for login page (edirsh@redhat.com)
- Redirect from old quickstart paths to new quickstart paths
  (edirsh@redhat.com)
- Added 'coming soon' to power page (edirsh@redhat.com)
- Fixed legal pages (edirsh@redhat.com)
- Added styling to the partner pages (edirsh@redhat.com)
- Styled dashboard (edirsh@redhat.com)
- And more of the link changing (edirsh@redhat.com)
- More of changing links from rh.com to www.rh.com (edirsh@redhat.com)
- Changed link to forums to www.rh.com/os so scary cert warning isn't triggered
  (edirsh@redhat.com)
- Changed register page title for consistency (edirsh@redhat.com)
- Updated home page with new illustrations; more styling tweaks
  (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Styled login, register, and terms forms (edirsh@redhat.com)
- Removed dialog-triggering javascript (edirsh@redhat.com)

* Mon Aug 01 2011 Dan McPherson <dmcphers@redhat.com> 0.75.9-1
- 

* Mon Aug 01 2011 Dan McPherson <dmcphers@redhat.com> 0.75.8-1
- test case fix (dmcphers@redhat.com)
- test case work (dmcphers@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Added web-based domain creation and editing (edirsh@redhat.com)
- Revert "Revert "Changed api urls in config to https"" (edirsh@redhat.com)
- Revert "Revert "Added domain interface back into site"" (edirsh@redhat.com)
- Revert "Revert "Added config variable for express api base url""
  (edirsh@redhat.com)
- Updated rest of the views to comply with new design (edirsh@redhat.com)
- Added power page (edirsh@redhat.com)

* Sun Jul 31 2011 Dan McPherson <dmcphers@redhat.com> 0.75.7-1
- Added flex page (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Express page completed, styled, and scripted (edirsh@redhat.com)
- minor fix (dmcphers@redhat.com)

* Thu Jul 28 2011 Dan McPherson <dmcphers@redhat.com> 0.75.6-1
- get site working in devenv (dmcphers@redhat.com)

* Thu Jul 28 2011 Dan McPherson <dmcphers@redhat.com> 0.75.5-1
- minor change (dmcphers@redhat.com)
- twitter error handling (dmcphers@redhat.com)
- show tweeters pic instead of retweeter (dmcphers@redhat.com)
- adding twitter, work in progress (dmcphers@redhat.com)
- New layout and homepage working, everything else is broken
  (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Updated conversion to latest version (edirsh@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.75.4-1
- fix test cases (dmcphers@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.75.3-1
- gemfile.lock fix (dmcphers@redhat.com)
- Copied in stand-alone site v2 conversion for sharing (edirsh@redhat.com)

* Mon Jul 25 2011 Dan McPherson <dmcphers@redhat.com> 0.75.2-1
- remove aws account number from flex request access (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Jul 18 2011 Dan McPherson <dmcphers@redhat.com> 0.74.8-1
- Adding flex images (mhicks@redhat.com)
- update local dev rails instructions (dmcphers@redhat.com)

* Sat Jul 16 2011 Dan McPherson <dmcphers@redhat.com> 0.74.7-1
- test case changes (dmcphers@redhat.com)

* Fri Jul 15 2011 Dan McPherson <dmcphers@redhat.com> 0.74.6-1
- make title consistent (dmcphers@redhat.com)

* Fri Jul 15 2011 Dan McPherson <dmcphers@redhat.com> 0.74.5-1
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Downgrade jQuery for video player compatibility (edirsh@redhat.com)
- fix site videos - Bug 721211 (dmcphers@redhat.com)
- Revert "Added config variable for express api base url" (edirsh@redhat.com)
- Revert "Added domain interface back into site" (edirsh@redhat.com)
- Revert "Changed api urls in config to https" (edirsh@redhat.com)
- libra_check fix #2 (mhicks@redhat.com)
- libra_check fix #1 in site (mhicks@redhat.com)
- Added more test coverage for access/exress controller (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Bug 721323 (dmcphers@redhat.com)
- Changed api urls in config to https (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Added domain interface back into site (edirsh@redhat.com)
- Added config variable for express api base url (edirsh@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.4-1
- 

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.3-1
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Minified universal js script (edirsh@redhat.com)
- Added click tracking code to try it buttons (edirsh@redhat.com)
- Added valid on-page omniture event tracking for successful registrations
  (edirsh@redhat.com)
- Removed code for invalid omniture on-page event tracking (edirsh@redhat.com)
- Changed omniture page ids to use openshift instead of rh (edirsh@redhat.com)
- Added getQueryParam plugin to Omniture code (edirsh@redhat.com)
- Corrected CouchConf banner in place (edirsh@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.74.2-1
- Automatic commit of package [rhc-site] release [0.74.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.13-1].
  (dmcphers@redhat.com)
- Removed front-end for domain creation (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.12-1].
  (dmcphers@redhat.com)
- update default streamline-aws server to webqa (dmcphers@redhat.com)
- Updated omniture dynamic account information (edirsh@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.11-1].
  (edirsh@redhat.com)
- Corrected getting_started page so selenium tests will pass
  (edirsh@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.10-1].
  (edirsh@redhat.com)
- Updated express api baseurl (edirsh@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.9-1].
  (edirsh@redhat.com)
- Updated tests to use new function names (edirsh@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.8-1].
  (edirsh@redhat.com)
- Prevent access to control panel (edirsh@redhat.com)
- Changed result checking from result parameter to data parameter
  (edirsh@redhat.com)
- Merge branch 'web-control-panel' (edirsh@redhat.com)
- Unfortunate giant commit - working domain creation form on getting started
  page (edirsh@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.7-1].
  (dmcphers@redhat.com)
- fixup embedded cart remove (dmcphers@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.6-1].
  (dmcphers@redhat.com)
- Added userinfo model (edirsh@redhat.com)
- Added login requirement to control panel (edirsh@redhat.com)
- Functioning remote form submission (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- Corrected docs link on getting started page (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.5-1].
  (dmcphers@redhat.com)
- Updated text under "Deploy in Minutes" headline on front page
  (edirsh@redhat.com)
- Bug 716885 - Added perl to lists of supported Express platforms
  (edirsh@redhat.com)
- Fixed broken video links and added correct video titles (edirsh@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.4-1].
  (dmcphers@redhat.com)
- Fixed broken documentation link (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- cleanup (dmcphers@redhat.com)
- cleanup (dmcphers@redhat.com)
- Automatic commit of package [rhc-site] release [0.73.3-1].
  (dmcphers@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.74.1-1
- bumping spec numbers (dmcphers@redhat.com)

* Thu Jul 07 2011 Dan McPherson <dmcphers@redhat.com> 0.73.13-1
- Removed front-end for domain creation (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Updated omniture dynamic account information (edirsh@redhat.com)

* Wed Jul 06 2011 Dan McPherson <dmcphers@redhat.com> 0.73.12-1
- update default streamline-aws server to webqa (dmcphers@redhat.com)

* Tue Jul 05 2011 Emily Dirsh <edirsh@redhat.com> 0.73.11-1
- Corrected getting_started page so selenium tests will pass
  (edirsh@redhat.com)

* Tue Jul 05 2011 Emily Dirsh <edirsh@redhat.com> 0.73.10-1
- Updated express api baseurl (edirsh@redhat.com)

* Tue Jul 05 2011 Emily Dirsh <edirsh@redhat.com> 0.73.9-1
- Updated tests to use new function names (edirsh@redhat.com)

* Tue Jul 05 2011 Emily Dirsh <edirsh@redhat.com> 0.73.8-1
- Prevent access to control panel (edirsh@redhat.com)
- Changed result checking from result parameter to data parameter
  (edirsh@redhat.com)
- Merge branch 'web-control-panel' (edirsh@redhat.com)
- Unfortunate giant commit - working domain creation form on getting started
  page (edirsh@redhat.com)
- Added userinfo model (edirsh@redhat.com)
- Added login requirement to control panel (edirsh@redhat.com)
- Functioning remote form submission (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- Merge branch 'em-dev' into web-control-panel (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- Added domain form to control panel (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- Added domain controller (edirsh@redhat.com)
- Added express api mixin tests (edirsh@redhat.com)
- Added unit tests for express_domain (edirsh@redhat.com)
- Merge branch 'master' into web-control-panel (edirsh@redhat.com)
- basic express api/domain model behavior written (edirsh@redhat.com)
- Model and controller for control-panel in place (edirsh@redhat.com)

* Fri Jul 01 2011 Dan McPherson <dmcphers@redhat.com> 0.73.7-1
- fixup embedded cart remove (dmcphers@redhat.com)

* Thu Jun 30 2011 Dan McPherson <dmcphers@redhat.com> 0.73.6-1
- Corrected docs link on getting started page (edirsh@redhat.com)

* Wed Jun 29 2011 Dan McPherson <dmcphers@redhat.com> 0.73.5-1
- Updated text under "Deploy in Minutes" headline on front page
  (edirsh@redhat.com)
- Bug 716885 - Added perl to lists of supported Express platforms
  (edirsh@redhat.com)
- Fixed broken video links and added correct video titles (edirsh@redhat.com)

* Tue Jun 28 2011 Dan McPherson <dmcphers@redhat.com> 0.73.4-1
- Fixed broken documentation link (edirsh@redhat.com)
- cleanup (dmcphers@redhat.com)
- cleanup (dmcphers@redhat.com)

* Tue Jun 28 2011 Dan McPherson <dmcphers@redhat.com> 0.73.3-1
- maven support (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.2-1
- 

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Jun 24 2011 Dan McPherson <dmcphers@redhat.com> 0.72.22-1
- Updated omniture account information (edirsh@redhat.com)

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.72.21-1
- fix indention within pre (dmcphers@redhat.com)
- fix haml syntax issue (dmcphers@redhat.com)
- better version of guide (jimjag@redhat.com)
- 2 spaces (jimjag@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (jimjag@redhat.com)
- Update site w/ OS X guide (jimjag@redhat.com)
- Made requested changes to omniture code (edirsh@redhat.com)

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.72.20-1
- Bug 715510 - fixed broken link on product pages (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- link naming consistency improvements (edirsh@redhat.com)

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.19-1
- deps in right order (dmcphers@redhat.com)
- Content updates on express page (edirsh@redhat.com)
- Content updates for flex page (edirsh@redhat.com)
- Merge branch 'master' of ssh://libragit/srv/git/li (edirsh@redhat.com)
- Content update for home page (edirsh@redhat.com)

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.18-1
- 

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.17-1
- going back to aws 2.4.5 (dmcphers@redhat.com)
- Added new conference banners (edirsh@redhat.com)
- Omniture tracking variables added (edirsh@redhat.com)

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.16-1
- aws 2.4.5 -> aws 2.5.5 (dmcphers@redhat.com)
- right_http_connection -> http_connection (dmcphers@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.72.15-1
- New banners (edirsh@redhat.com)

* Fri Jun 17 2011 Dan McPherson <dmcphers@redhat.com> 0.72.14-1
- get tests running again (dmcphers@redhat.com)
- Gemfile dev updates (dmcphers@redhat.com)

* Thu Jun 16 2011 Matt Hicks <mhicks@redhat.com> 0.72.13-1
- Merge branch 'master' into streamline (mhicks@redhat.com)
- Merge branch 'master' into streamline (mhicks@redhat.com)
- Refactoring the streamline modules (mhicks@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.12-1
- update gem deps for site (dmcphers@redhat.com)

* Wed Jun 15 2011 Dan McPherson <dmcphers@redhat.com> 0.72.11-1
- 

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.10-1
- Bug 707402 - First form field is focused on page load with javascript
  (edirsh@redhat.com)
- Bug 712173 / US553 - Added new omniture code to site (edirsh@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.9-1
- doc fix (dmcphers@redhat.com)

* Wed Jun 08 2011 Matt Hicks <mhicks@redhat.com> 0.72.8-1
- 

* Wed Jun 08 2011 Matt Hicks <mhicks@redhat.com> 0.72.7-1
- Minor updates

* Wed Jun 08 2011 Dan McPherson <dmcphers@redhat.com> 0.72.6-1
- functioning migration (dmcphers@redhat.com)
- migration progress (dmcphers@redhat.com)

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.5-1
- build fixes (dmcphers@redhat.com)
- Bug 710244 (dmcphers@redhat.com)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.4-1
- Adding RPM Obsoletes to make upgrade cleaner (mhicks@redhat.com)
- controller.conf install fixup (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.3-1
- add mod_ssl to site and broker (dmcphers@redhat.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- fix site tests (dmcphers@redhat.com)
- fix broken access denied case (dmcphers@redhat.com)
- Bug 708244 (dmcphers@redhat.com)
- Bug 707745 (dmcphers@redhat.com)
- Bug 707488 (dmcphers@redhat.com)
- fix site dep list (dmcphers@redhat.com)
- more jboss renaming changes (dmcphers@redhat.com)
- fix app link (dmcphers@redhat.com)

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Reducing duplicate listing in %files
- Marking config as no-replace
- Creating run directory on installation

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
