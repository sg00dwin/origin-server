%define htmldir %{_localstatedir}/www/html
%define sitedir %{_localstatedir}/www/libra/site

Summary:   Li site components
Name:      rhc-site
Version:   0.85.3
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
Requires:  ruby-geoip
Requires:  rubygem-passenger-native-libs
Requires:  rubygem-rails
Requires:  rubygem-json
Requires:  rubygem-parseconfig
Requires:  rubygem-xml-simple
Requires:  rubygem-formtastic
Requires:  rubygem-haml
Requires:  rubygem-recaptcha
Requires:  rubygem-hpricot
Requires:  rubygem-barista
Requires:  js

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
mkdir -p -m 770 %{buildroot}%{sitedir}/tmp
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
chmod 0770 %{sitedir}/tmp

%changelog
* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.85.3-1
- Fix documentation links (aboone@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- Adding Flex Monitoring and Scaling video for Chinese viewers
  (aboone@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- bump spec numbers (dmcphers@redhat.com)
- Adding China-hosted Flex - Deploying Seam video (BZ 773191)
  (aboone@redhat.com)

* Thu Jan 12 2012 Dan McPherson <dmcphers@redhat.com> 0.84.17-1
- Adding PostgreSQL to Express offering on Features comparison page
  (aboone@redhat.com)

* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.84.16-1
- Pass key_type to broker when creating/updating domain (aboone@redhat.com)

* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.84.15-1
- Add MongoDB to Express feature set on Features page (aboone@redhat.com)
- Revert changes to Features page made in 4950348 and 17b869f (fix for
  BZ773161) (aboone@redhat.com)

* Tue Jan 10 2012 Dan McPherson <dmcphers@redhat.com> 0.84.14-1
- Fix for "XSS" issues in BZ 759362 (aboone@redhat.com)
- Use valid XHTML markup for video embed (aboone@redhat.com)
- Also rename partial to be consistent with actual video domain name (related
  to 2a0cd3f) (aboone@redhat.com)
- Correct typo in Chinese video domain name (aboone@redhat.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.84.13-1
- Show "video not available" message for videos without a Chinese equivalent
  (aboone@redhat.com)
- Updates to password form for US1602 (fotios@redhat.com)

* Mon Jan 09 2012 Alex Boone <aboone@redhat.com> 0.84.12-1
- 

* Mon Jan 09 2012 Alex Boone <aboone@redhat.com> 0.84.11-1
- Use an alternative video host for Chinese site visitors (aboone@redhat.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.84.10-1
- Fix grammar error (BZ 771835) (aboone@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.9-1
- scss: purple link looks web 1.0 (hylkebons@gmail.com)
- scss: cleaner plain page style (hylkebons@gmail.com)
- scss: footer and copyright (hylkebons@gmail.com)
- New features page (hylkebons@gmail.com)
- New features page (hylkebons@gmail.com)

* Wed Jan 04 2012 Alex Boone <aboone@redhat.com> 0.84.8-1
- Periodically re-verify the SSO ticket (fixes exploit from BZ 753981)
  (aboone@redhat.com)
- remove unused method (dmcphers@redhat.com)

* Tue Jan 03 2012 Dan McPherson <dmcphers@redhat.com> 0.84.7-1
- moving streamline into site (dmcphers@redhat.com)
- Corrected typo on express product page (edirsh@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.84.6-1
- Fix BZ 767477 - When on a register page, prefer content form to dialog
  (aboone@redhat.com)

* Tue Dec 20 2011 Alex Boone <aboone@redhat.com> 0.84.5-1
- Fix devenv logins (regression from 1931b89) - only use .redhat.com domain
  cookies in integrated config (aboone@redhat.com)

* Tue Dec 20 2011 Mike McGrath <mmcgrath@redhat.com> 0.84.4-1
- Fix BZ 759619 - sanitize location.hash before using as jQuery selector
  (aboone@redhat.com)

* Fri Dec 16 2011 Dan McPherson <dmcphers@redhat.com> 0.84.3-1
- Fix for Bug 765906: Promo email problem (fotios@redhat.com)
- some cleanup of server-common (dmcphers@redhat.com)

* Thu Dec 15 2011 Dan McPherson <dmcphers@redhat.com> 0.84.2-1
- Removed message truncation and added CSS to enable word wrapping
  (fotios@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.84.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.83.11-1
- Fix integration tests broken with commit 1931b89 (aboone@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.83.10-1
- Redirect logged-in users trying to access the login page (aboone@redhat.com)
- Fix for devenv mock login, actually allow proper log out (aboone@redhat.com)

* Tue Dec 13 2011 Dan McPherson <dmcphers@redhat.com> 0.83.9-1
- Fixes for BZ 759002: (aboone@redhat.com)
- Fixed the way form.js determines AJAX workflow (fotios@redhat.com)
- Fix a variable name bug in b5b7832 (aboone@redhat.com)
- Fix for BZ766490: Modified dialog message CSS and javascript to truncate long
  messages and added a margin to prevent overlap with close button
  (fotios@redhat.com)

* Mon Dec 12 2011 Dan McPherson <dmcphers@redhat.com> 0.83.8-1
- Small changes to product overview styling (edirsh@redhat.com)
- put min-width on body so that text does not overflow onto dark bg
  (edirsh@redhat.com)

* Sun Dec 11 2011 Dan McPherson <dmcphers@redhat.com> 0.83.7-1
- Also ignore whitespace-only promo code entries (aboone@redhat.com)
- Properly check for the presence of a promo code (aboone@redhat.com)
- Added ability to disable forms while waiting for AJAX (for US1489). Also
  DRYed up some of the form processing (fotios@redhat.com)

* Thu Dec 08 2011 Alex Boone <aboone@redhat.com> 0.83.6-1
- 

* Thu Dec 08 2011 Alex Boone <aboone@redhat.com> 0.83.5-1
- Fix for BZ 758976 - display fieldset legend in white text in IE
  (aboone@redhat.com)
- Bump jQuery.validate to 1.9.0, spinner on ajax:beforeSend instead of submit
  (IE8 fixes) (aboone@redhat.com)
- Get rid of console.log statement (breaks in IE) (aboone@redhat.com)

* Tue Dec 06 2011 Alex Boone <aboone@redhat.com> 0.83.4-1
- Removed all references to Power on /app (ffranz@redhat.com)
- Removed all references to Power on /app (ffranz@redhat.com)
- Modified password reset for to prevent double submission. Dialogs are also
  cleared when closed (fotios@redhat.com)
- Point to fully-qualified URL for openshift.repo config, not available in all
  envs (aboone@redhat.com)
- Use sensible permissions on icons (aboone@redhat.com)

* Sat Dec 03 2011 Mike McGrath <mmcgrath@redhat.com> 0.83.3-1
- Added server side validation for SSH keys for BZ 759362 and 755375
  (fotios@redhat.com)

* Fri Dec 02 2011 Dan McPherson <dmcphers@redhat.com> 0.83.2-1
- Now using compass compile --no-line-comments to compile CSS
  (ffranz@redhat.com)
- Fixes 749297 - now on IE 8 (ffranz@redhat.com)

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.83.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.82.17-1
- Fix for BZ 758976 - prevent promo code label from getting shifted over
  (aboone@redhat.com)

* Wed Nov 30 2011 Dan McPherson <dmcphers@redhat.com> 0.82.16-1
- Fix for 758628 - shorten long SSH keys in error message (aboone@redhat.com)
- Added style.css to site once the build process is not compass compiling it
  automagically (ffranz@redhat.com)
- Added style.css to site once the build process is not compass compiling it
  automagically (ffranz@redhat.com)
- Compiled JS for c5440f7 (cope with long usernames in nav) (aboone@redhat.com)
- Added style.css to site once the build process is not compass compiling it
  automagically (ffranz@redhat.com)

* Mon Nov 28 2011 Dan McPherson <dmcphers@redhat.com> 0.82.15-1
- Fixes 749297 - truncates the username line with ellipsis when it's too large
  (ffranz@redhat.com)
- Change the way spinners are kicked off, ajaxSubmit is not defined so use
  default submitHandler (aboone@redhat.com)
- Fix a JS error when no location.hash is present (aboone@redhat.com)
- Fix coffeescript compilation issue with extended chars (aboone@redhat.com)

* Fri Nov 25 2011 Dan McPherson <dmcphers@redhat.com> 0.82.14-1
- Fixes 749297 - truncates the username line with ellipsis when it's too large
  (ffranz@redhat.com)

* Wed Nov 23 2011 Dan McPherson <dmcphers@redhat.com> 0.82.13-1
- Fix for control_panel_controller functional test (aboone@redhat.com)
- Only show an error page for an unknown error in control panel
  (aboone@redhat.com)

* Wed Nov 23 2011 Dan McPherson <dmcphers@redhat.com> 0.82.12-1
- Fix control_panel controller functional tests I broke in a01e02e
  (aboone@redhat.com)

* Tue Nov 22 2011 Dan McPherson <dmcphers@redhat.com> 0.82.11-1
- 

* Tue Nov 22 2011 Dan McPherson <dmcphers@redhat.com> 0.82.10-1
- comment out test cases (dmcphers@redhat.com)
- Fix for BZ 744675 -- switch to parent section which contains the referenced
  element (aboone@redhat.com)

* Tue Nov 22 2011 Dan McPherson <dmcphers@redhat.com> 0.82.9-1
- Show error page in control_panel when broker request excepts (BZ 728383)
  (aboone@redhat.com)

* Tue Nov 22 2011 Dan McPherson <dmcphers@redhat.com> 0.82.8-1
- Reinstate outage notification mechanism (BZ 744498) (aboone@redhat.com)

* Mon Nov 21 2011 Dan McPherson <dmcphers@redhat.com> 0.82.7-1
- Fix for BZ 755375 - html-entitize invalid SSH key to prevent injecting JS
  into error msg (aboone@redhat.com)

* Thu Nov 17 2011 Dan McPherson <dmcphers@redhat.com> 0.82.6-1
- 

* Thu Nov 17 2011 Dan McPherson <dmcphers@redhat.com> 0.82.5-1
- US1441: Promotional code email notification and omniture tracking. Adding
  missing mailer class. (kraman@gmail.com)
- Prevent page from jumping when sticky nav sticks (aboone@redhat.com)
- US1441: Promotional code email notification and omniture tracking
  (kraman@gmail.com)
- Fix for BZ #753981 - properly log out of RedHat.com SSO (aboone@redhat.com)

* Thu Nov 17 2011 Dan McPherson <dmcphers@redhat.com> 0.82.4-1
- fix test case (dmcphers@redhat.com)

* Tue Nov 15 2011 Dan McPherson <dmcphers@redhat.com> 0.82.3-1
- Fix for BZ 730430 - update SSH key form with cleansed key (aboone@redhat.com)

* Sat Nov 12 2011 Dan McPherson <dmcphers@redhat.com> 0.82.2-1
- Fixing the cart list and the assertion order (mhicks@redhat.com)
- Fix alignment of wrapped lines in app list (edirsh@redhat.com)
- Change domain to namespace (edirsh@redhat.com)
- Include new cartridges in cartlist, but don't show them in the create app
  form (edirsh@redhat.com)

* Thu Nov 10 2011 Dan McPherson <dmcphers@redhat.com> 0.82.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Nov 10 2011 Dan McPherson <dmcphers@redhat.com> 0.81.10-1
- Bug 752721 - shorten ssh key when updated with javascript (edirsh@redhat.com)
- Merge remote-tracking branch 'origin/sauce' (aboone@redhat.com)
- Merge remote-tracking branch 'origin' into sauce (aboone@redhat.com)
- Merge remote-tracking branch 'origin/master' into sauce (aboone@redhat.com)
- Updated tests to use sauce_testing cookie for bypassing certain checks
  (fotios@redhat.com)
- Added jquery.cookie.js (fotios@redhat.com)

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.9-1
- Remove logging from javascripts as they were causing errors in IE Also
  checking in generated scripts as barista doesn't seem to be working
  consistently on the devenvs (edirsh@redhat.com)
- Remove audio detection from modernizr as IE9 doesn't like it
  (edirsh@redhat.com)
- Bug 751978 - round two. (edirsh@redhat.com)

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.8-1
- Compiled javascript for 0168cbd (aboone@redhat.com)

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.7-1
- Added spinners to login, signup, password change, and reset forms
  (fotios@redhat.com)

* Tue Nov 08 2011 Alex Boone <aboone@redhat.com> 0.81.6-1
- Fix bug 751981 - reload apps after a domain change (aboone@redhat.com)
- Fix delete dialogs not hiding when finished (edirsh@redhat.com)
- Display ssh placeholder text on control panel if ssh key is 'nossh'
  (edirsh@redhat.com)
- Bug 751978 - a few styling tweaks to improve the app list (edirsh@redhat.com)
- Bug 751984 (edirsh@redhat.com)
- Bug 751986 - clarify language in app deletion form (edirsh@redhat.com)
- Bug 751791 - corrected video link in console (edirsh@redhat.com)
- Bug 751980 - check in missing image (edirsh@redhat.com)

* Mon Nov 07 2011 Dan McPherson <dmcphers@redhat.com> 0.81.5-1
- Small styling and content tweaks, and checking in generated files
  (edirsh@redhat.com)
- Add previously untracked but needed partial template (edirsh@redhat.com)
- Squashed commit of console-update branch (edirsh@redhat.com)

* Thu Nov 03 2011 Dan McPherson <dmcphers@redhat.com> 0.81.4-1
- Take related videos out of embedded videos (edirsh@redhat.com)

* Wed Nov 02 2011 Dan McPherson <dmcphers@redhat.com> 0.81.3-1
- Pass user information to express app model, so app creation will work in non-
  integrated env (edirsh@redhat.com)

* Tue Nov 01 2011 Dan McPherson <dmcphers@redhat.com> 0.81.2-1
- Fix small screen display bug (edirsh@redhat.com)

* Thu Oct 27 2011 Dan McPherson <dmcphers@redhat.com> 0.81.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Oct 26 2011 Dan McPherson <dmcphers@redhat.com> 0.80.9-1
- Prevent omniture code from launching in development Rails env. It was
  noticably slowing down Sauce tests. (fotios@redhat.com)

* Tue Oct 25 2011 Dan McPherson <dmcphers@redhat.com> 0.80.8-1
- Cleaning up documentation (mhicks@redhat.com)

* Fri Oct 21 2011 Dan McPherson <dmcphers@redhat.com> 0.80.7-1
- Update text on site (edirsh@redhat.com)

* Tue Oct 18 2011 Dan McPherson <dmcphers@redhat.com> 0.80.6-1
- 

* Tue Oct 18 2011 Dan McPherson <dmcphers@redhat.com> 0.80.5-1
- 

* Tue Oct 18 2011 Dan McPherson <dmcphers@redhat.com> 0.80.4-1
- bump httparty version (dmcphers@redhat.com)

* Tue Oct 18 2011 Matt Hicks <mhicks@redhat.com> 0.80.3-1
- Moving to Amazon's aws-sdk rubygem (mhicks@redhat.com)

* Mon Oct 17 2011 Dan McPherson <dmcphers@redhat.com> 0.80.2-1
- Change text in footer per request by Legal (edirsh@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.80.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.9-1
- Bug 745275 (edirsh@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.8-1
- Add express specific workflow to compensate for new default login redirect
  (edirsh@redhat.com)
- Change default login workflow path to overview page instead of express page
  (edirsh@redhat.com)
- Fixed logging in without javascript. Fixes mechanize/naios scripts for Flex
  team (fotios@redhat.com)

* Sat Oct 08 2011 Dan McPherson <dmcphers@redhat.com> 0.79.7-1
- add multimap and regin as Gemfile deps (dmcphers@redhat.com)
- add new deps (dmcphers@redhat.com)
- update Gemfiles (dmcphers@redhat.com)

* Tue Oct 04 2011 Dan McPherson <dmcphers@redhat.com> 0.79.6-1
- Added streamline timing to HTTP requests (fotios@redhat.com)
- RFC (jimjag@redhat.com)

* Mon Oct 03 2011 Dan McPherson <dmcphers@redhat.com> 0.79.5-1
- Reverting DRYed up streamline configs for now (fotios@redhat.com)

* Mon Oct 03 2011 Dan McPherson <dmcphers@redhat.com> 0.79.4-1
- Fixed Rails missing for cucumber tests (fotios@redhat.com)
- Navigation changes (edirsh@redhat.com)
- Bug 742429 (edirsh@redhat.com)
- DRYed up streamline configuration variables (fotios@redhat.com)

* Fri Sep 30 2011 Dan McPherson <dmcphers@redhat.com> 0.79.3-1
- Fixed production.rb to use resetPassword.html (fotios@redhat.com)
- Fixed development.rb (fotios@redhat.com)
- Fixed production password reset URL (fotios@redhat.com)
- Fixed development password reset URL (fotios@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.79.2-1
- Remove unnecessary logging (edirsh@redhat.com)
- Bug 730430 - ssh oddities (edirsh@redhat.com)
- Patch rack/utils to fix cookie validation in streamline (fotios@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.79.1-1
- bump spec numbers (dmcphers@redhat.com)
- bug 742168 (dmcphers@redhat.com)

* Wed Sep 28 2011 Dan McPherson <dmcphers@redhat.com> 0.78.20-1
- Fixed form focus flow. Fixed selenium artifact creation (fotios@redhat.com)
- Improve consistency in naming and linking to control panel
  (edirsh@redhat.com)
- Improve client-side validation of express apps/domains (edirsh@redhat.com)
- Add features page (edirsh@redhat.com)
- Minor changes to client-side validation (edirsh@redhat.com)
- Polish form styling (edirsh@redhat.com)

* Tue Sep 27 2011 Dan McPherson <dmcphers@redhat.com> 0.78.19-1
- Add timeout to http call to broker in web interface (edirsh@redhat.com)

* Tue Sep 27 2011 Dan McPherson <dmcphers@redhat.com> 0.78.18-1
- Hard code cartridge list for now (edirsh@redhat.com)

* Mon Sep 26 2011 Dan McPherson <dmcphers@redhat.com> 0.78.17-1
- Removed .orig file from bad merge (fotios@redhat.com)
- Added password change functionality (fotios@redhat.com)

* Mon Sep 26 2011 Dan McPherson <dmcphers@redhat.com> 0.78.16-1
- separate streamline secrets (dmcphers@redhat.com)
- Fixed dialogs not hiding if user_box exists (fotios@redhat.com)
- Made AJAX forms work with validation (fotios@redhat.com)
- Make product overview titles links, add brief summary for each product
  (edirsh@redhat.com)
- Add correct page title to overview page (edirsh@redhat.com)
- Check in compiled stylesheet (edirsh@redhat.com)
- Fix product overview classes to more accurately reflect status
  (edirsh@redhat.com)
- Bug 741174 (edirsh@redhat.com)
- Add images used for overview page (edirsh@redhat.com)
- Update product colors (edirsh@redhat.com)
- Modify site navigation for new page (edirsh@redhat.com)

* Sat Sep 24 2011 Dan McPherson <dmcphers@redhat.com> 0.78.15-1
- 

* Sat Sep 24 2011 Dan McPherson <dmcphers@redhat.com> 0.78.14-1
- Add overview page - squashed commit (edirsh@redhat.com)

* Fri Sep 23 2011 Dan McPherson <dmcphers@redhat.com> 0.78.13-1
- Added password reset form (fotios@redhat.com)
- Fixed user controller and signup form for cloud access choice
  (fotios@redhat.com)
- DRYed up dialogs. Fixed problem with form not submitting for correct account
  type (fotios@redhat.com)

* Thu Sep 22 2011 Dan McPherson <dmcphers@redhat.com> 0.78.12-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (fotios@redhat.com)
- Changed workflow handling for AJAX calls (fotios@redhat.com)
- Bug 740176 (edirsh@redhat.com)
- Bug 740183 - Correct form alignment in dialogs (edirsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (fotios@redhat.com)
- Fix for bug 740147 by making sure workflows are set for AJAX
  (fotios@redhat.com)
- Rewrite twitter javascripts to be reusable elsewhere on the site
  (edirsh@redhat.com)
- Cleanup unused javascripts (edirsh@redhat.com)

* Mon Sep 19 2011 Dan McPherson <dmcphers@redhat.com> 0.78.11-1
- bug 735924 (dmcphers@redhat.com)

* Thu Sep 15 2011 Dan McPherson <dmcphers@redhat.com> 0.78.10-1
- Added js to site.spec for rubygem-js (fotios@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (fotios@redhat.com)
- Fixed login#ajax to work properly on non-integrated envs (fotios@redhat.com)
- Temporary commit to build (fotios@redhat.com)

* Wed Sep 14 2011 Dan McPherson <dmcphers@redhat.com> 0.78.9-1
- disable client gem release (temp) beginnings of broker auth adding barista to
  spec (dmcphers@redhat.com)
- Fixed some loud warnings (fotios@redhat.com)
- Squashed commit of the following: (fotios@redhat.com)

* Tue Sep 13 2011 Dan McPherson <dmcphers@redhat.com> 0.78.8-1
- Changed test/functional/user_controller_test to better test for @user.errors
  not containing any values (fotios@redhat.com)
- Enabled popup AJAX forms (fotios@redhat.com)
- Enabled AJAX forms for current login and register pages (fotios@redhat.com)

* Tue Sep 13 2011 Dan McPherson <dmcphers@redhat.com> 0.78.7-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (fotios@redhat.com)
- Fixed lost password link (fotios@redhat.com)

* Tue Sep 13 2011 Dan McPherson <dmcphers@redhat.com> 0.78.6-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (fotios@redhat.com)
- Changed Rails.configuration.streamline to be a hash. Changed references to
  build URIs from that hash (fotios@redhat.com)
- Bug 735924 (dmcphers@redhat.com)

* Mon Sep 12 2011 Dan McPherson <dmcphers@redhat.com> 0.78.5-1
- revert changes to get a build working (dmcphers@redhat.com)
- Removed AJAX form stuff (fotios@redhat.com)
- removing whitespace to fix warning (mmcgrath@redhat.com)

* Mon Sep 12 2011 Dan McPherson <dmcphers@redhat.com> 0.78.4-1
- Fixed merge issue between 8c296a2 and e005456 modifying same code
  (fotios@redhat.com)

* Mon Sep 12 2011 Dan McPherson <dmcphers@redhat.com> 0.78.3-1
- Added support for AJAX login and register forms. DRYed up the forms to all
  use the same partials (fotios@redhat.com)
- Change default email confirm redirection path to the express page
  (edirsh@redhat.com)
- Add javascript response to ajax login (edirsh@redhat.com)

* Fri Sep 09 2011 Matt Hicks <mhicks@redhat.com> 0.78.2-1
- Fixed form_tag to unbreak HAML (fotios@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (fotios@redhat.com)
- Fix haml error in sign-in dialog (edirsh@redhat.com)
- Fixed warnings in control_panel_helper_test (fotios@redhat.com)
- Added funcionality for AJAX login form (fotios@redhat.com)
- Enabled AJAX login form with no logic (fotios@redhat.com)
- Bug 735280 (edirsh@redhat.com)
- Change spinner text to accurately reflect domain action (edirsh@redhat.com)
- Add close button to app creation promo dialog (edirsh@redhat.com)
- Add unauthorized paths and remove unused authorized paths from login flows
  test (edirsh@redhat.com)
- Further improvements to main graphic styling (edirsh@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.78.1-1
- bump spec numbers (dmcphers@redhat.com)
- Changed login#create to better mimic streamline. Added tests for workflow
  integration (fotios@redhat.com)
- Add max_express_apps to remaining environment config files
  (edirsh@redhat.com)
- Small style improvements (edirsh@redhat.com)

* Wed Aug 31 2011 Dan McPherson <dmcphers@redhat.com> 0.77.11-1
- default to /app/express if nothing else is chosen (dmcphers@redhat.com)
- minor syntax change (dmcphers@redhat.com)
- minor rework of login logic (dmcphers@redhat.com)
- Improve styling of opening text on home page (edirsh@redhat.com)
- Bug 734638 (edirsh@redhat.com)
- Bug 734644 (edirsh@redhat.com)

* Tue Aug 30 2011 Dan McPherson <dmcphers@redhat.com> 0.77.10-1
- couple renames (dmcphers@redhat.com)
- login cleanup (dmcphers@redhat.com)
- Bug 734370 - Change url of applications after domain is updated
  (edirsh@redhat.com)
- Bug 734342; Add max apps config variable to streamline-aws environment
  (edirsh@redhat.com)

* Tue Aug 30 2011 Dan McPherson <dmcphers@redhat.com> 0.77.9-1
- error handling and test cases (dmcphers@redhat.com)
- change wording (dmcphers@redhat.com)
- get test cases working (dmcphers@redhat.com)
- get test cases working (dmcphers@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.8-1
- get test cases running (dmcphers@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.7-1
- revert development.rb back (dmcphers@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.6-1
- error handling fix (dmcphers@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.5-1
- cleanup (dmcphers@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.4-1
- add external register (dmcphers@redhat.com)
- Add create app functionality (edirsh@redhat.com)
- Updated graphics and styles (edirsh@redhat.com)

* Fri Aug 26 2011 Dan McPherson <dmcphers@redhat.com> 0.77.3-1
- Added functional tests for control panel controller (fotios@redhat.com)

* Thu Aug 25 2011 Dan McPherson <dmcphers@redhat.com> 0.77.2-1
- Added more functional tests for User controller (fotios@redhat.com)

* Fri Aug 19 2011 Matt Hicks <mhicks@redhat.com> 0.77.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Aug 19 2011 Dan McPherson <dmcphers@redhat.com> 0.76.11-1
- 

* Fri Aug 19 2011 Dan McPherson <dmcphers@redhat.com> 0.76.10-1
- Bug 731927 (dmcphers@redhat.com)
- Bug 731932 (dmcphers@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.9-1
- Redirect /app/user to /app/user/new on get request (edirsh@redhat.com)

* Mon Aug 15 2011 Matt Hicks <mhicks@redhat.com> 0.76.8-1
- Test case to verify no terms short-circuit (mhicks@redhat.com)
- Cleanup of old 'try it' logic (mhicks@redhat.com)
- Removing original files (mhicks@redhat.com)
- Only grant access once terms are accepted (mhicks@redhat.com)
- undo accidental commit of env (dmcphers@redhat.com)

* Sun Aug 14 2011 Dan McPherson <dmcphers@redhat.com> 0.76.7-1
- fix flex registration to take you to flex after loggin in
  (dmcphers@redhat.com)
- set twitter image size (dmcphers@redhat.com)
- Some routing improvements (mhicks@redhat.com)

* Fri Aug 12 2011 Matt Hicks <mhicks@redhat.com> 0.76.6-1
- Simplified user registration changes (mhicks@redhat.com)

* Thu Aug 11 2011 Matt Hicks <mhicks@redhat.com> 0.76.5-1
- buffer latest tweet for retweets (dmcphers@redhat.com)
- fix twitter retweet images (dmcphers@redhat.com)
- bug 729560 (dmcphers@redhat.com)

* Tue Aug 09 2011 Dan McPherson <dmcphers@redhat.com> 0.76.4-1
- Modify banner yet again (edirsh@redhat.com)
- Subdue java banner (edirsh@redhat.com)
- Tweak free flex announcment color (edirsh@redhat.com)
- Add Free flex terms to flex page (edirsh@redhat.com)
- Use RH brand colors (edirsh@redhat.com)
- twitter fixes (dmcphers@redhat.com)
- Fix twitter avatar (edirsh@redhat.com)
- Add product to registration event tracking (edirsh@redhat.com)
- Add new announcements (edirsh@redhat.com)
- Add java announcement banner (edirsh@redhat.com)

* Mon Aug 08 2011 Dan McPherson <dmcphers@redhat.com> 0.76.3-1
- add server side cache for twitter feeds (dmcphers@redhat.com)
- Change dashboard to console and add flex console link to dashboard
  (edirsh@redhat.com)

* Sun Aug 07 2011 Dan McPherson <dmcphers@redhat.com> 0.76.2-1
- add gem dep (dmcphers@redhat.com)
- Fix invalid link (edirsh@redhat.com)
- Add link validation testing (edirsh@redhat.com)
- selenium work (dmcphers@redhat.com)
- get selenium up and running again (dmcphers@redhat.com)

* Fri Aug 05 2011 Dan McPherson <dmcphers@redhat.com> 0.76.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Aug 05 2011 Dan McPherson <dmcphers@redhat.com> 0.75.17-1
- Added trademark indicators to RedHat logos (edirsh@redhat.com)
- Add product var to try it link tracking for omniture (edirsh@redhat.com)

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
