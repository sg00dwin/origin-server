%define htmldir %{_localstatedir}/www/html
%define brokerdir %{_localstatedir}/www/libra/broker

Summary:   Li broker components
Name:      rhc-broker
Version:   0.75.2
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-broker-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-common
Requires:  rhc-server-common
Requires:  httpd
Requires:  mod_ssl
Requires:  mod_passenger
Requires:  rubygem-aws
Requires:  rubygem-json
Requires:  rubygem-parseconfig
Requires:  rubygem-passenger-native-libs
Requires:  rubygem-rails
Requires:  rubygem-xml-simple

Obsoletes: rhc-server

BuildArch: noarch

%description
This contains the broker 'controlling' components of OpenShift.
This includes the public APIs for the client tools.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{brokerdir}
cp -r . %{buildroot}%{brokerdir}
ln -s %{brokerdir}/public %{buildroot}%{htmldir}/broker

mkdir -p %{buildroot}%{brokerdir}/run
mkdir -p %{buildroot}%{brokerdir}/log
touch %{buildroot}%{brokerdir}/log/production.log


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,-,-) %{brokerdir}/log/production.log
%config(noreplace) %{brokerdir}/config/environments/production.rb
%{brokerdir}
%{htmldir}/broker

%post
/bin/touch %{brokerdir}/log/production.log

%changelog
* Mon Jul 25 2011 Dan McPherson <dmcphers@redhat.com> 0.75.2-1
- remove aws account number from flex request access (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Jul 15 2011 Dan McPherson <dmcphers@redhat.com> 0.74.3-1
- Bug 721258 (dmcphers@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.74.2-1
- Automatic commit of package [rhc-broker] release [0.74.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.12-1].
  (dmcphers@redhat.com)
- handle errors from controller and properly delete failed app creations
  (dmcphers@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.11-1].
  (dmcphers@redhat.com)
- remove embed param passing to broker and doc updates (dmcphers@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.10-1].
  (edirsh@redhat.com)
- Bug 719005 (dmcphers@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.9-1].
  (edirsh@redhat.com)
- consistent names (dmcphers@redhat.com)
- Hide the "type" logic (jimjag@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.8-1].
  (dmcphers@redhat.com)
- fixup embedded cart remove (dmcphers@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.7-1].
  (dmcphers@redhat.com)
- cleanup (dmcphers@redhat.com)
- perf improvements for how/when we look up the valid cart types on the server
  (dmcphers@redhat.com)
- move health check path to server (dmcphers@redhat.com)
- change broker session name (dmcphers@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.6-1].
  (dmcphers@redhat.com)
- sso support for broker (dmcphers@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.5-1].
  (dmcphers@redhat.com)
- undo passing rhlogin to cart (dmcphers@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)
- fixing merge from Dan (mmcgrath@redhat.com)
- Added initial S3 bits (mmcgrath@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.4-1].
  (mhicks@redhat.com)
- allow messsages from cart to client (dmcphers@redhat.com)
- Added support to call embedded cartridges (mmcgrath@redhat.com)
- Added embedded list (mmcgrath@redhat.com)
- Automatic commit of package [rhc-broker] release [0.73.3-1].
  (dmcphers@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.74.1-1
- bumping spec numbers (dmcphers@redhat.com)

* Sat Jul 09 2011 Dan McPherson <dmcphers@redhat.com> 0.73.12-1
- handle errors from controller and properly delete failed app creations
  (dmcphers@redhat.com)

* Thu Jul 07 2011 Dan McPherson <dmcphers@redhat.com> 0.73.11-1
- remove embed param passing to broker and doc updates (dmcphers@redhat.com)

* Tue Jul 05 2011 Emily Dirsh <edirsh@redhat.com> 0.73.10-1
- Bug 719005 (dmcphers@redhat.com)

* Fri Jul 01 2011 Emily Dirsh <edirsh@redhat.com> 0.73.9-1
- consistent names (dmcphers@redhat.com)
- Hide the "type" logic (jimjag@redhat.com)

* Fri Jul 01 2011 Dan McPherson <dmcphers@redhat.com> 0.73.8-1
- fixup embedded cart remove (dmcphers@redhat.com)

* Thu Jun 30 2011 Dan McPherson <dmcphers@redhat.com> 0.73.7-1
- cleanup (dmcphers@redhat.com)
- perf improvements for how/when we look up the valid cart types on the server
  (dmcphers@redhat.com)
- move health check path to server (dmcphers@redhat.com)
- change broker session name (dmcphers@redhat.com)

* Thu Jun 30 2011 Dan McPherson <dmcphers@redhat.com> 0.73.6-1
- sso support for broker (dmcphers@redhat.com)

* Wed Jun 29 2011 Dan McPherson <dmcphers@redhat.com> 0.73.5-1
- undo passing rhlogin to cart (dmcphers@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)
- fixing merge from Dan (mmcgrath@redhat.com)
- Added initial S3 bits (mmcgrath@redhat.com)

* Tue Jun 28 2011 Matt Hicks <mhicks@redhat.com> 0.73.4-1
- allow messsages from cart to client (dmcphers@redhat.com)
- Added support to call embedded cartridges (mmcgrath@redhat.com)
- Added embedded list (mmcgrath@redhat.com)

* Tue Jun 28 2011 Dan McPherson <dmcphers@redhat.com> 0.73.3-1
- maven support (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.2-1
- workaround for mcollective taking options (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Jun 24 2011 Dan McPherson <dmcphers@redhat.com> 0.72.19-1
- add app_scope to broker (dmcphers@redhat.com)

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.18-1
- Merging for alpha order (mmcgrath@redhat.com)
- trying this out (mmcgrath@redhat.com)

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.17-1
- 

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.16-1
- going back to aws 2.4.5 (dmcphers@redhat.com)

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.15-1
- aws 2.4.5 -> aws 2.5.5 (dmcphers@redhat.com)
- right_http_connection -> http_connection (dmcphers@redhat.com)

* Thu Jun 16 2011 Matt Hicks <mhicks@redhat.com> 0.72.14-1
- Merge branch 'master' into streamline (mhicks@redhat.com)
- Merge branch 'master' into streamline (mhicks@redhat.com)
- Refactoring the streamline modules (mhicks@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.13-1
- add error if invalid cart sent to server (dmcphers@redhat.com)
- update gem deps for site (dmcphers@redhat.com)

* Wed Jun 15 2011 Dan McPherson <dmcphers@redhat.com> 0.72.12-1
- add cart_types param to cartlist call (dmcphers@redhat.com)
- Don't render error (jimjag@redhat.com)

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.11-1
- rename to make more sense... (jimjag@redhat.com)
- parse from array (jimjag@redhat.com)
- Pass string (jimjag@redhat.com)
- Force list to be a string... xfer to array when conv (jimjag@redhat.com)
- nil is an error... but no idea how we are getting it (at the worst, we should
  get an empty list) (jimjag@redhat.com)
- naming (jimjag@redhat.com)
- revert... I am stumped. (jimjag@redhat.com)
- force usage of dummy arg (jimjag@redhat.com)
- simple name change (jimjag@redhat.com)
- scoping (jimjag@redhat.com)
- use class (jimjag@redhat.com)
- force method (jimjag@redhat.com)
- and allow req to be accepted (jimjag@redhat.com)
- be consistent (jimjag@redhat.com)
- Pass debug flag (jimjag@redhat.com)
- pull into client tools cartinfo (jimjag@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.10-1
- Move along to more dynamic using :carts factor (jimjag@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.9-1
- format fix (dmcphers@redhat.com)
- error code cleanup (dmcphers@redhat.com)
- Creating test commits, this is for jenkins (mmcgrath@redhat.com)

* Thu Jun 09 2011 Matt Hicks <mhicks@redhat.com> 0.72.8-1
- Adding validation for our various vars (mmcgrath@redhat.com)

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.7-1
- build fixes (dmcphers@redhat.com)
- Bug 706329 (dmcphers@redhat.com)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.6-1
- Adding RPM Obsoletes to make upgrade cleaner (mhicks@redhat.com)
- controller.conf install fixup (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.5-1
- Automatic commit of package [rhc-broker] release [0.72.4-1].
  (dmcphers@redhat.com)
- Automatic commit of package [rhc-broker] release [0.72.3-1].
  (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.4-1
- 

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.3-1
- app-uuid patch from dev/markllama/app-uuid
  69b077104e3227a73cbf101def9279fe1131025e (markllama@gmail.com)
- add mod_ssl to site and broker (dmcphers@redhat.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- Bug 707745 (dmcphers@redhat.com)
- get site and broker working on restructure (dmcphers@redhat.com)
- Spec commit history fix (mhicks@redhat.com)
- refactoring changes (dmcphers@redhat.com)

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-3
- Reducing duplicate listing in %files
- Marking config as no-replace
- Creating run directory on installation

* Wed May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Fixing sym link to buildroot

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
