%define htmldir %{_localstatedir}/www/html
%define sitedir %{_localstatedir}/www/libra/site

Summary:   Li site components
Name:      rhc-site
Version:   0.73.10
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
