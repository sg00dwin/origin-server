%define htmldir %{_localstatedir}/www/html
%define brokerdir %{_localstatedir}/www/libra/broker

Summary:   Li broker components
Name:      rhc-broker
Version:   0.84.40
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

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,-,-) %{brokerdir}/log/production.log
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

%post
/bin/touch %{brokerdir}/log/production.log

%changelog
* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.84.40-1
- Automatic commit of package [rhc-broker] release [0.84.39-1].
  (dmcphers@redhat.com)

* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.84.39-1
- Updating gem versions (dmcphers@redhat.com)
- correctly return 400 for invalid requests (dmcphers@redhat.com)

* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.84.38-1
- Updating gem versions (dmcphers@redhat.com)
- Bug 773248 and 773186 (dmcphers@redhat.com)

* Tue Jan 10 2012 Dan McPherson <dmcphers@redhat.com> 0.84.37-1
- Updating gem versions (dmcphers@redhat.com)
- Fix for Bug# 772673 -Persist ssh key type in the datastore (currently in s3)
  (rpenta@redhat.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.84.36-1
- Updating gem versions (dmcphers@redhat.com)
- Move jenkins deconfigure to observer. Create convinence method to move app
  deconfigure and user update logic from admin script and cloud-sdk controller
  to cloud-sdk models. (kraman@gmail.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.84.35-1
- Updating gem versions (dmcphers@redhat.com)
- TA1166: Move outage notification out of cloud-sdk controller to broker
  component (kraman@gmail.com)
- enable nurture by default for prod settings (dmcphers@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.34-1
- fix typo (dmcphers@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.33-1
- fixing syntax (dmcphers@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.32-1
- config.integrated under auth (dmcphers@redhat.com)
- stop changing rpc_opts in admin scripts for now (dmcphers@redhat.com)
- cleanup params (dmcphers@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.31-1
- Updating gem versions (dmcphers@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.30-1
- Bug 772151 (dmcphers@redhat.com)

* Thu Jan 05 2012 Dan McPherson <dmcphers@redhat.com> 0.84.29-1
- allow move of postgresql (dmcphers@redhat.com)

* Thu Jan 05 2012 Dan McPherson <dmcphers@redhat.com> 0.84.28-1
- mysql and mongo move (dmcphers@redhat.com)
- fix dns exception (dmcphers@redhat.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.84.27-1
- Updating gem versions (dmcphers@redhat.com)
- US1608: support DSA keys (rpenta@redhat.com)
- US1608: support DSA keys (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- bug-fixes related to Mirage/express merge (rpenta@redhat.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.84.26-1
- Updating gem versions (dmcphers@redhat.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.84.25-1
- Updating gem versions (dmcphers@redhat.com)
- use user exception (dmcphers@redhat.com)
- Adding cloud-sdk-controller unit tests (kraman@gmail.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.84.24-1
- Updating gem versions (dmcphers@redhat.com)
- better rollback logic (dmcphers@redhat.com)

* Wed Jan 04 2012 Alex Boone <aboone@redhat.com> 0.84.23-1
- Updating gem versions (aboone@redhat.com)

* Wed Jan 04 2012 Alex Boone <aboone@redhat.com> 0.84.22-1
- move fixes (dmcphers@redhat.com)

* Tue Jan 03 2012 Dan McPherson <dmcphers@redhat.com> 0.84.21-1
- streamline fix (dmcphers@redhat.com)

* Tue Jan 03 2012 Dan McPherson <dmcphers@redhat.com> 0.84.20-1
- switch if around (dmcphers@redhat.com)

* Tue Jan 03 2012 Dan McPherson <dmcphers@redhat.com> 0.84.19-1
- getting streamline working properly (dmcphers@redhat.com)
- fixup production.rb to be closer to prod settings (dmcphers@redhat.com)
- get nurture/apptegic working again (dmcphers@redhat.com)

* Wed Dec 28 2011 Dan McPherson <dmcphers@redhat.com> 0.84.18-1
- Updating gem versions (dmcphers@redhat.com)

* Tue Dec 27 2011 Dan McPherson <dmcphers@redhat.com> 0.84.17-1
- Updating gem versions (dmcphers@redhat.com)
- better logging (dmcphers@redhat.com)
- various fixes (dmcphers@redhat.com)
- various fixed (dmcphers@redhat.com)
- add application limit of 5 (dmcphers@redhat.com)

* Tue Dec 27 2011 Dan McPherson <dmcphers@redhat.com> 0.84.16-1
- Updating gem versions (dmcphers@redhat.com)

* Tue Dec 27 2011 Dan McPherson <dmcphers@redhat.com> 0.84.15-1
- Updating gem versions (dmcphers@redhat.com)
- Bug 770544 (dmcphers@redhat.com)

* Mon Dec 26 2011 Dan McPherson <dmcphers@redhat.com> 0.84.14-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 770406 (dmcphers@redhat.com)
- Bug 770364 (dmcphers@redhat.com)

* Fri Dec 23 2011 Dan McPherson <dmcphers@redhat.com> 0.84.13-1
- bump spec number (dmcphers@redhat.com)

* Fri Dec 23 2011 Dan McPherson <dmcphers@redhat.com> 0.84.12-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 77027 (dmcphers@redhat.com)
- Bug 770085 (dmcphers@redhat.com)
- reverted 11996f1b2f12b378ca420e002097203654ac4fb2 and implemented Dan\'s
  suggestion (jhonce@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.84.11-1
- bump spec numbers (dmcphers@redhat.com)
- removing more of server-common (dmcphers@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.84.10-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 768851 - allow jboss build with only large instance available (devenv)
  (dmcphers@redhat.com)
- Fixed broken here document for warning (jhonce@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.84.9-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 768851 (dmcphers@redhat.com)

* Wed Dec 21 2011 Dan McPherson <dmcphers@redhat.com> 0.84.8-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 21 2011 Dan McPherson <dmcphers@redhat.com> 0.84.7-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 769663 (dmcphers@redhat.com)

* Wed Dec 21 2011 Dan McPherson <dmcphers@redhat.com> 0.84.6-1
- fix spec numbers (dmcphers@redhat.com)

* Fri Dec 16 2011 Dan McPherson <dmcphers@redhat.com> 0.84.5-1
- rework rekey broker auth logic (dmcphers@redhat.com)
- some cleanup of server-common (dmcphers@redhat.com)

* Thu Dec 15 2011 Dan McPherson <dmcphers@redhat.com> 0.84.4-1
- add cloud-sdk-controller prereq (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.84.3-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.84.2-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.84.1-1
- bump spec numbers (dmcphers@redhat.com)
- Merge remote-tracking branch 'origin/master' (kraman@gmail.com)
- Adding cartridge list cache. Added nossh to validation for ssh key (BZ
  767442). Based on 2cbab9d374409 Added secondary ssh key management based on
  Ravi's work (kraman@gmail.com)
- Merge remote-tracking branch 'origin/mirage' (kraman@gmail.com)
- rhc-admin-move completed (kraman@gmail.com)
- fix typo (dmcphers@redhat.com)
- Adding first version of app move admin utility (kraman@gmail.com)
- Added ability to add/remove/list secondary ssh keys Added admin tools
  (kraman@gmail.com)
- fix stopped status (dmcphers@redhat.com)
- get status working (dmcphers@redhat.com)
- get create domain working (dmcphers@redhat.com)
- merge code for deletion of namespace into cloud-sdk (rchopra@redhat.com)
- Merge remote-tracking branch 'origin/master' into mirage (kraman@gmail.com)
- Added application, cloud_user observers to validate objects and print jenkins
  related warnings. Added per application user delegation (with ssh keys)
  (kraman@gmail.com)
- Merge remote-tracking branch 'origin/master' into mirage (kraman@gmail.com)
- building cloud sdk (dmcphers@redhat.com)
- Changed cdk-controller to be rails plugin. Modified express-broker with
  customizations and integrating cdk-controller (kraman@gmail.com)
- Checkpoint of cloud-sdk work. Added implementation and bugfixes for
  Datastore, Auth and node-communication user-info works (kraman@gmail.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.83.9-1
- Accept "nossh" as a valid ssh key in the broker as it's needed by the web
  site (BZ 767442) (aboone@redhat.com)

* Tue Dec 13 2011 Dan McPherson <dmcphers@redhat.com> 0.83.8-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Multi-key : move addition of ssh key to new app into libra.rb
  (rpenta@redhat.com)
- Multile ssh-keys: allow "action=update-key" (rpenta@redhat.com)

* Tue Dec 13 2011 Dan McPherson <dmcphers@redhat.com> 0.83.7-1
- Cache cartridge list, default TTL of 1 hour (aboone@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Multi-key support: bug-fixes (rpenta@redhat.com)
- fixing permissions (mmcgrath@redhat.com)
- Multi-key support: Update <key-name>:<ssh-pubkey> info s3/user.json, nuke app
  specific ssh key info (rpenta@redhat.com)

* Mon Dec 12 2011 Dan McPherson <dmcphers@redhat.com> 0.83.6-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Multi-user rest api: Use 'action'=add-user/remove-user/list-users instead of
  add-user=true/false (rpenta@redhat.com)

* Mon Dec 12 2011 Dan McPherson <dmcphers@redhat.com> 0.83.5-1
- fix broker build (dmcphers@redhat.com)
- add scripts to /usr/bin (lnader@dhcp-240-165.mad.redhat.com)

* Sun Dec 11 2011 Dan McPherson <dmcphers@redhat.com> 0.83.4-1
- move common dep (dmcphers@redhat.com)
- remove popen usage and better migration output (dmcphers@redhat.com)
- multi-user bug-fixes: 'force' param usage is confusing, removing the option
  (rpenta@redhat.com)
- Support for managing multiple sub-users for the RHN/openshift account
  (rpenta@redhat.com)

* Thu Dec 08 2011 Alex Boone <aboone@redhat.com> 0.83.3-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- implementation of US1366 : REST support for domain deletion
  (rchopra@redhat.com)

* Wed Dec 07 2011 Mike McGrath <mmcgrath@redhat.com> 0.83.2-1
- US1443 - admin tools (lnader@dhcp-240-165.mad.redhat.com)

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.83.1-1
- bump spec numbers (dmcphers@redhat.com)
- add open4 require to broker (dmcphers@redhat.com)

* Wed Nov 16 2011 Dan McPherson <dmcphers@redhat.com> 0.82.6-1
- Bug 754013 (dmcphers@redhat.com)

* Wed Nov 16 2011 Dan McPherson <dmcphers@redhat.com> 0.82.5-1
- bump min timeout to 30secs from broker scripts (dmcphers@redhat.com)
- more rhc-get-user-info details + move logging (dmcphers@redhat.com)

* Tue Nov 15 2011 Dan McPherson <dmcphers@redhat.com> 0.82.4-1
- 

* Tue Nov 15 2011 Dan McPherson <dmcphers@redhat.com> 0.82.3-1
- add tidy (dmcphers@redhat.com)
- add deconfigure app on node script (dmcphers@redhat.com)

* Sat Nov 12 2011 Dan McPherson <dmcphers@redhat.com> 0.82.2-1
- workable rsa create script (dmcphers@redhat.com)

* Thu Nov 10 2011 Dan McPherson <dmcphers@redhat.com> 0.82.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.11-1
- bug 752341 (dmcphers@redhat.com)

* Tue Nov 08 2011 Dan McPherson <dmcphers@redhat.com> 0.81.10-1
- move maven build size to build.sh env var (dmcphers@redhat.com)

* Mon Nov 07 2011 Dan McPherson <dmcphers@redhat.com> 0.81.9-1
- Added an explicit check for rhcloud.com (mmcgrath@redhat.com)

* Sat Nov 05 2011 Dan McPherson <dmcphers@redhat.com> 0.81.8-1
- Adding auto enable jenkins (dmcphers@redhat.com)

* Thu Nov 03 2011 Dan McPherson <dmcphers@redhat.com> 0.81.7-1
- move updates, add pre_build (dmcphers@redhat.com)

* Wed Nov 02 2011 Dan McPherson <dmcphers@redhat.com> 0.81.6-1
- merging (mmcgrath@redhat.com)
- Allowing alias add / remove (mmcgrath@redhat.com)

* Wed Nov 02 2011 Dan McPherson <dmcphers@redhat.com> 0.81.5-1
- fix move for jboss (dmcphers@redhat.com)
- adding move script and error handling...  just missing embedded apps now
  (dmcphers@redhat.com)

* Tue Nov 01 2011 Dan McPherson <dmcphers@redhat.com> 0.81.4-1
- move app, work in progress (dmcphers@redhat.com)

* Fri Oct 28 2011 Dan McPherson <dmcphers@redhat.com> 0.81.3-1
- better error handling (dmcphers@redhat.com)

* Thu Oct 27 2011 Dan McPherson <dmcphers@redhat.com> 0.81.2-1
- remove requirement to pass cartridge to ctl commands (dmcphers@redhat.com)

* Thu Oct 27 2011 Dan McPherson <dmcphers@redhat.com> 0.81.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Oct 26 2011 Dan McPherson <dmcphers@redhat.com> 0.80.8-1
- bug 749081 (dmcphers@redhat.com)
- move app info for embedded carts to separate call (dmcphers@redhat.com)

* Fri Oct 21 2011 Dan McPherson <dmcphers@redhat.com> 0.80.7-1
- up app name limit to 32 (dmcphers@redhat.com)

* Fri Oct 21 2011 Dan McPherson <dmcphers@redhat.com> 0.80.6-1
- add user agent to apptegic (dmcphers@redhat.com)

* Tue Oct 18 2011 Dan McPherson <dmcphers@redhat.com> 0.80.5-1
- 

* Tue Oct 18 2011 Dan McPherson <dmcphers@redhat.com> 0.80.4-1
- bump httparty version (dmcphers@redhat.com)

* Tue Oct 18 2011 Matt Hicks <mhicks@redhat.com> 0.80.3-1
- Moving to Amazon's aws-sdk rubygem (mhicks@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.2-1
- Temporary commit to build (dmcphers@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.80.1-1
- bump spec numbers (dmcphers@redhat.com)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.79.5-1
- add authentication to jenkins (dmcphers@redhat.com)

* Sat Oct 08 2011 Dan McPherson <dmcphers@redhat.com> 0.79.4-1
- correcting Gemfile (mmcgrath@redhat.com)
- add multimap and regin as Gemfile deps (dmcphers@redhat.com)
- add new deps (dmcphers@redhat.com)
- update Gemfiles (dmcphers@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.79.3-1
- add concept of CLIENT_ERROR and use from phpmyadmin (dmcphers@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.79.2-1
- 

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.79.1-1
- bump spec numbers (dmcphers@redhat.com)
- env var add/remove (dmcphers@redhat.com)

* Wed Sep 28 2011 Dan McPherson <dmcphers@redhat.com> 0.78.9-1
- add node profile to rhc-cartridge-do (dmcphers@redhat.com)

* Mon Sep 26 2011 Dan McPherson <dmcphers@redhat.com> 0.78.8-1
- separate streamline secrets (dmcphers@redhat.com)
- Fixing the help for the namespace command (mhicks@redhat.com)
- Moving namespace script to the broker (mhicks@redhat.com)
- let ssh key alter work with multiple keys (dmcphers@redhat.com)

* Thu Sep 22 2011 Dan McPherson <dmcphers@redhat.com> 0.78.7-1
- change broker secret_token.rb (dmcphers@redhat.com)
- perm changes on jenkins_id_rsa and allow user_info calls from broker auth key
  (dmcphers@redhat.com)
- move broker auth to params (dmcphers@redhat.com)

* Tue Sep 20 2011 Dan McPherson <dmcphers@redhat.com> 0.78.6-1
- correcting var name (mmcgrath@redhat.com)
- Adding node_profile type (mmcgrath@redhat.com)
- Added node profile to broker configs (mmcgrath@redhat.com)
- call add and remove ssh keys from jenkins configure and deconfigure
  (dmcphers@redhat.com)

* Mon Sep 19 2011 Dan McPherson <dmcphers@redhat.com> 0.78.5-1
- change blacklist message (dmcphers@redhat.com)

* Thu Sep 15 2011 Dan McPherson <dmcphers@redhat.com> 0.78.4-1
- adding iv encryption (dmcphers@redhat.com)
- param checking (dmcphers@redhat.com)
- broker auth working (dmcphers@redhat.com)
- broker auth key validation (dmcphers@redhat.com)
- move broker_auth_secret to controller.conf (dmcphers@redhat.com)

* Wed Sep 14 2011 Dan McPherson <dmcphers@redhat.com> 0.78.3-1
- disable client gem release (temp) beginnings of broker auth adding barista to
  spec (dmcphers@redhat.com)

* Tue Sep 13 2011 Dan McPherson <dmcphers@redhat.com> 0.78.2-1
- Fixed Rails.configuration.streamline in broker config/environments
  (fotios@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.78.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.2-1
- better error handling (dmcphers@redhat.com)

* Fri Aug 19 2011 Matt Hicks <mhicks@redhat.com> 0.77.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Aug 15 2011 Dan McPherson <dmcphers@redhat.com> 0.76.8-1
- fix typo (dmcphers@redhat.com)

* Mon Aug 15 2011 Matt Hicks <mhicks@redhat.com> 0.76.7-1
- rename li-controller-0.1 to li-controller (dmcphers@redhat.com)

* Sun Aug 14 2011 Dan McPherson <dmcphers@redhat.com> 0.76.6-1
- Use \d regex patter for clarity pull broker and server-side api from any/all
  responses if possible protect against parse errors (jimjag@redhat.com)

* Thu Aug 11 2011 Matt Hicks <mhicks@redhat.com> 0.76.5-1
- tuck away client API Allow for 1.1.11 (eg) (jimjag@redhat.com)

* Tue Aug 09 2011 Dan McPherson <dmcphers@redhat.com> 0.76.4-1
- added api value (mmcgrath@redhat.com)
- Adjust ordering (jimjag@redhat.com)
- Some prelim API and broker versioning (jimjag@redhat.com)

* Mon Aug 08 2011 Matt Hicks <mhicks@redhat.com> 0.76.3-1
- Apptegic Integration (mhicks@redhat.com)

* Fri Aug 05 2011 Dan McPherson <dmcphers@redhat.com> 0.76.2-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Aug 01 2011 Dan McPherson <dmcphers@redhat.com> 0.75.5-1
- 

* Mon Aug 01 2011 Dan McPherson <dmcphers@redhat.com> 0.75.4-1
- test case work (dmcphers@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.75.3-1
- gemfile.lock fix (dmcphers@redhat.com)

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
