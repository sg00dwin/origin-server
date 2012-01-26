%define htmldir %{_localstatedir}/www/html
%define brokerdir %{_localstatedir}/www/libra/broker

Summary:   Li broker components
Name:      rhc-broker
Version:   0.85.18
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-broker-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-server-common
Requires:  httpd
Requires:  mod_ssl
Requires:  mod_passenger
Requires:  rubygem-json
Requires:  rubygem-parseconfig
Requires:  rubygem-passenger-native-libs
Requires:  rubygem-rails
Requires:  rubygem-xml-simple
Requires:  rubygem-cloud-sdk-controller

BuildArch: noarch

%description
This contains the broker 'controlling' components of OpenShift.
This includes the public APIs for the client tools.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{htmldir}
mkdir -p %{buildroot}%{brokerdir}
cp -r . %{buildroot}%{brokerdir}
ln -s %{brokerdir}/public %{buildroot}%{htmldir}/broker

mkdir -p %{buildroot}%{brokerdir}/run
mkdir -p %{buildroot}%{brokerdir}/log
touch %{buildroot}%{brokerdir}/log/production.log
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-domain %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-app %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-cartridge-do %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-deconfigure-on-node %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-move %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-ctl-district %{buildroot}/%{_bindir}
mv %{buildroot}%{brokerdir}/script/rhc-admin-create-district %{buildroot}/%{_bindir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,-,-) %{brokerdir}/log/production.log
%attr(0666,-,-) %{brokerdir}/log/development.log
%config(noreplace) %{brokerdir}/config/environments/production.rb
%config(noreplace) %{brokerdir}/config/keys/public.pem
%config(noreplace) %{brokerdir}/config/keys/private.pem
%attr(0600,-,-) %config(noreplace) %{brokerdir}/config/keys/rsync_id_rsa
%config(noreplace) %{brokerdir}/config/keys/rsync_id_rsa.pub
%attr(0750,-,-) %{brokerdir}/config/keys/generate_rsa_keys
%attr(0750,-,-) %{brokerdir}/config/keys/generate_rsync_rsa_keys
%attr(0750,-,-) %{brokerdir}/script
%{brokerdir}
%{htmldir}/broker
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-domain
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-app
%attr(0750,-,-) %{_bindir}/rhc-admin-cartridge-do
%attr(0750,-,-) %{_bindir}/rhc-admin-deconfigure-on-node
%attr(0750,-,-) %{_bindir}/rhc-admin-move
%attr(0750,-,-) %{_bindir}/rhc-admin-ctl-district
%attr(0750,-,-) %{_bindir}/rhc-admin-create-district

%post
/bin/touch %{brokerdir}/log/development.log
/bin/touch %{brokerdir}/log/production.log

%changelog
* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.18-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- resolve merge conflicts (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Resolve merge conflicts (rpenta@redhat.com)
- Resolve merge conflicts (rpenta@redhat.com)
- ssh keys code refactor (rpenta@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.17-1
- Updating gem versions (dmcphers@redhat.com)
- fix test case (dmcphers@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.16-1
- Updating gem versions (dmcphers@redhat.com)
- fix test cases (dmcphers@redhat.com)
- make move district aware (dmcphers@redhat.com)
- move gear limit checking to mongo (dmcphers@redhat.com)
- Bug 784130 (dmcphers@redhat.com)
- improve mongo usage (dmcphers@redhat.com)
- lots of district error handling (dmcphers@redhat.com)

* Fri Jan 20 2012 Dan McPherson <dmcphers@redhat.com> 0.85.15-1
- Updating gem versions (dmcphers@redhat.com)
- build fixes (dmcphers@redhat.com)
- fix build (dmcphers@redhat.com)

* Fri Jan 20 2012 Dan McPherson <dmcphers@redhat.com> 0.85.14-1
- Updating gem versions (dmcphers@redhat.com)
- getting to the real districts mongo impl (dmcphers@redhat.com)

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.13-1
- Updating gem versions (mmcgrath@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.12-1
- 

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.11-1
- Updating gem versions (dmcphers@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.10-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Merge remote branch 'origin/REST' (lnader@dhcp-240-165.mad.redhat.com)
- Merge remote branch 'origin/master' into REST
  (lnader@dhcp-240-165.mad.redhat.com)
- Added new method to auth service with support for user/pass based
  authentication for new REST API (kraman@gmail.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.9-1
- Updating gem versions (dmcphers@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.8-1
- Updating gem versions (dmcphers@redhat.com)
- district work (dmcphers@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.7-1
- Updating gem versions (dmcphers@redhat.com)
- fix build (dmcphers@redhat.com)

* Wed Jan 18 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.6-1
- Updating gem versions (mmcgrath@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- mongo datastore fixes (rpenta@redhat.com)
- use two different collections (dmcphers@redhat.com)
- add broker mongo extensions (dmcphers@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.85.5-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- handle app being removed during migration (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- configure/start mongod service for new devenv launch (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge/resolve conflicts from master (rpenta@redhat.com)
- s3-to-mongo: code cleanup (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- fixes related to mongo datastore (rpenta@redhat.com)
- merge changes from master (rpenta@redhat.com)
- s3-to-mongo: bug fixes (rpenta@redhat.com)
- Merge changes from master (rpenta@redhat.com)
- Added MongoDataStore model (rpenta@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.4-1
- remove broker gem refs for threaddump (bdecoste@gmail.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.3-1
- US1667: threaddump for rack (wdecoste@localhost.localdomain)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (wdecoste@localhost.localdomain)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (wdecoste@localhost.localdomain)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (wdecoste@localhost.localdomain)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (wdecoste@localhost.localdomain)
- Temporary commit to build (wdecoste@localhost.localdomain)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- Updating gem versions (dmcphers@redhat.com)
- districts (work in progress) (dmcphers@redhat.com)
- fix get all users with app named user.json (dmcphers@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- Bug 781254 (dmcphers@redhat.com)
