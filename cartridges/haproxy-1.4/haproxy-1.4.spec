%define cartridgedir %{_libexecdir}/stickshift/cartridges/haproxy-1.4

Summary:   Provides haproxy-1.4 support
Name:      rhc-cartridge-haproxy-1.4
Version:   0.6.2
Release:   1%{?dist}
Group:     Development/Languages
License:   ASL 2.0
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: git
Requires:  stickshift-abstract
Requires:  haproxy
Requires:  rubygem-daemons

BuildArch: noarch

%description
Provides haproxy balancer support to OpenShift

%prep
%setup -q

%build
rm -rf git_template
cp -r template/ git_template/
cd git_template
git init
git add -f .
git commit -m 'Creating template'
cd ..
git clone --bare git_template git_template.git
rm -rf git_template
touch git_template.git/refs/heads/.gitignore

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/stickshift/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/stickshift/cartridges/%{name}
cp -r info %{buildroot}%{cartridgedir}/
cp LICENSE %{buildroot}%{cartridgedir}/
cp COPYRIGHT %{buildroot}%{cartridgedir}/
mkdir -p %{buildroot}%{cartridgedir}/info/data/
cp -r git_template.git %{buildroot}%{cartridgedir}/info/data/
ln -s %{cartridgedir}/../abstract/info/hooks/add-module %{buildroot}%{cartridgedir}/info/hooks/add-module
ln -s %{cartridgedir}/../abstract/info/hooks/info %{buildroot}%{cartridgedir}/info/hooks/info
ln -s %{cartridgedir}/../abstract/info/hooks/post-install %{buildroot}%{cartridgedir}/info/hooks/post-install
ln -s %{cartridgedir}/../abstract/info/hooks/post-remove %{buildroot}%{cartridgedir}/info/hooks/post-remove
ln -s %{cartridgedir}/../abstract/info/hooks/reload %{buildroot}%{cartridgedir}/info/hooks/reload
ln -s %{cartridgedir}/../abstract/info/hooks/remove-module %{buildroot}%{cartridgedir}/info/hooks/remove-module
ln -s %{cartridgedir}/../abstract/info/hooks/restart %{buildroot}%{cartridgedir}/info/hooks/restart
ln -s %{cartridgedir}/../abstract/info/hooks/start %{buildroot}%{cartridgedir}/info/hooks/start
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/status %{buildroot}%{cartridgedir}/info/hooks/status
ln -s %{cartridgedir}/../abstract/info/hooks/stop %{buildroot}%{cartridgedir}/info/hooks/stop
ln -s %{cartridgedir}/../abstract/info/hooks/update-namespace %{buildroot}%{cartridgedir}/info/hooks/update-namespace
ln -s %{cartridgedir}/../abstract/info/hooks/remove-httpd-proxy %{buildroot}%{cartridgedir}/info/hooks/remove-httpd-proxy
ln -s %{cartridgedir}/../abstract/info/hooks/force-stop %{buildroot}%{cartridgedir}/info/hooks/force-stop
ln -s %{cartridgedir}/../abstract/info/hooks/add-alias %{buildroot}%{cartridgedir}/info/hooks/add-alias
ln -s %{cartridgedir}/../abstract/info/hooks/tidy %{buildroot}%{cartridgedir}/info/hooks/tidy
ln -s %{cartridgedir}/../abstract/info/hooks/remove-alias %{buildroot}%{cartridgedir}/info/hooks/remove-alias
ln -s %{cartridgedir}/../abstract/info/hooks/move %{buildroot}%{cartridgedir}/info/hooks/move
ln -s %{cartridgedir}/../abstract/info/hooks/threaddump %{buildroot}%{cartridgedir}/info/hooks/threaddump
ln -s %{cartridgedir}/../abstract/info/hooks/system-messages %{buildroot}%{cartridgedir}/info/hooks/system-messages
mkdir -p %{buildroot}%{cartridgedir}/info/connection-hooks/
ln -s %{cartridgedir}/../abstract/info/connection-hooks/set-db-connection-info %{buildroot}%{cartridgedir}/info/connection-hooks/set-db-connection-info

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/data/
%attr(0750,-,-) %{cartridgedir}/info/build/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%attr(0755,-,-) %{cartridgedir}/info/connection-hooks/
%config(noreplace) %{cartridgedir}/info/configuration/
%{_sysconfdir}/stickshift/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control
%{cartridgedir}/info/manifest.yml
%doc %{cartridgedir}/COPYRIGHT
%doc %{cartridgedir}/LICENSE

%changelog
* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.6.2-1
- Batch variable name chage (rmillner@redhat.com)
- Fix merge issues (kraman@gmail.com)
- Adding export control files (kraman@gmail.com)
- replacing references to libra with stickshift (abhgupta@redhat.com)
- libra to stickshift changes for haproxy - untested (abhgupta@redhat.com)
- partial set of libra-to-stickshift changes for haproxy (abhgupta@redhat.com)
- Renaming Cloud-SDK -> StickShift (kraman@gmail.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- added README (mmcgrath@redhat.com)
- removed comments (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- disabling ctld for now (mmcgrath@redhat.com)
- finalizing some haproxy ctld bits (mmcgrath@redhat.com)
- Modify haproxy connection hooks to source env variables correctly.
  (ramr@redhat.com)
- Bug fix - redirect streams only after the fd is opened. (ramr@redhat.com)
- Jenkens templates switch to proper gear size names (rmillner@redhat.com)
- Temporary commit to build (mmcgrath@redhat.com)
- Temporary commit to build (mmcgrath@redhat.com)
- accept any 200 response code (jhonce@redhat.com)
- disabling haproxy_ctld_daemon (mmcgrath@redhat.com)
- Adding cookie management to haproxy and general cleanup (mmcgrath@redhat.com)
- removed a bunch of add/remove gear cruft (mmcgrath@redhat.com)
- renaming haproxy watcher daemons (mmcgrath@redhat.com)
- added a watcher script, fixed up tracker logic (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- WIP removed extraneous debugging code (jhonce@redhat.com)
- renamed haproxy_status (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- adding more gearup/geardown logic (mmcgrath@redhat.com)
- WIP add/remove/create gear (jhonce@redhat.com)
- Removed new instances of GNU license headers (jhonce@redhat.com)

* Fri Mar 02 2012 Dan McPherson <dmcphers@redhat.com> 0.6.1-1
- bump spec numbers (dmcphers@redhat.com)
- add/remove gear via SDK (jhonce@redhat.com)

* Wed Feb 29 2012 Dan McPherson <dmcphers@redhat.com> 0.5.7-1
- Cleanup to put the ss-connector-execute workaround in the utility extensions
  for express. (ramr@redhat.com)
- Handle git push errors - better check for gear is up and running.
  (ramr@redhat.com)

* Tue Feb 28 2012 Dan McPherson <dmcphers@redhat.com> 0.5.6-1
- Need to wait for dns entries to become available -- we do need some other
  mechanism to ensure connection-hooks are invoked after everything works in
  dns. For now fix the bug by waiting in here for the dns entry to become
  available. (ramr@redhat.com)
- Bug fix to get haproxy reload working. (ramr@redhat.com)
- Fixup reload haproxy - temporary bandaid until ss-connector execute is
  fixed. (ramr@redhat.com)
- Manage gear reg/unreg from haproxy on scale up/down + reload haproxy
  gracefully. (ramr@redhat.com)
- ~/.state tracking feature (jhonce@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.5.5-1
- Fix inter-device move failure to cat + rm. (ramr@redhat.com)
- Remove git entries on gear removal (scale down). (ramr@redhat.com)

* Sat Feb 25 2012 Dan McPherson <dmcphers@redhat.com> 0.5.4-1
- Fix bugs to get gear sync + registration + scale up working.
  (ramr@redhat.com)
- Update handling k=v pairs the broker sends. Also check dns availability of
  the gear before attempting to use it. (ramr@redhat.com)
- Add a git remote for all-gears (allows: git push all-gears --mirror).
  (ramr@redhat.com)
- Blanket purge proxy ports on application teardown. (rmillner@redhat.com)
- Fix bugs + cleanup for broker integration. (ramr@redhat.com)
- Use connectors to sync gears and add routes. (ramr@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.5.3-1
- spec fix to include connection-hooks (rchopra@redhat.com)
- checkpoint 3 - horizontal scaling, minor fixes, connector hook for haproxy
  not complete (rchopra@redhat.com)
- checkpoint 2 - option to create scalable type of app, scaleup/scaledown apis
  added, group minimum requirements get fulfilled (rchopra@redhat.com)

* Mon Feb 20 2012 Dan McPherson <dmcphers@redhat.com> 0.5.2-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Made scripts more generic, still only works with php (mmcgrath@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.5.1-1
- bump spec numbers (dmcphers@redhat.com)
- fixing ssh permissions (mmcgrath@redhat.com)
- Adding git-repo setups (mmcgrath@redhat.com)
- Adding more ssh pre-configuring (mmcgrath@redhat.com)
- removed preconfigure from specfile, it's now provided (mmcgrath@redhat.com)
- Added ssh key and broker key (mmcgrath@redhat.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.4.2-1
- removing debug (mmcgrath@redhat.com)
- Adding sourcing for ctl_all to work (mmcgrath@redhat.com)
- Added add/remove gear (mmcgrath@redhat.com)
- added add/remove logic (mmcgrath@redhat.com)
- Adding basic gear_ctl script (mmcgrath@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.4.1-1
- add a digit to haproxy version (dmcphers@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.4-1
- fixing filler 1 (mmcgrath@redhat.com)
- added whitespace for test chante (mmcgrath@redhat.com)
- bug 722828 (bdecoste@gmail.com)
- more abstracting out selinux (dmcphers@redhat.com)
- better name consistency (dmcphers@redhat.com)
- first pass at splitting out selinux logic (dmcphers@redhat.com)
- merging (mmcgrath@redhat.com)
- Fix wrong link to remove-httpd-proxy (hypens not underscores) and fix
  manifests for Node and Python to allow for nodejs/python app creation.
  (ramr@redhat.com)
- correcting haproxy name (mmcgrath@redhat.com)
- Fix HAProxy descriptor Add HAProxy to standalone cart list on
  CartridgeCache(temp till descriptor changes are made on stickshift-node)
  (kraman@gmail.com)
- Altered haproxy (mmcgrath@redhat.com)
- removed dependency on www-dynamic (rchopra@redhat.com)

* Mon Feb 06 2012 Mike McGrath <mmcgrath@redhat.com> 0.3-1
- Adding legal bits (mmcgrath@redhat.com)

* Mon Feb 06 2012 Mike McGrath <mmcgrath@redhat.com> 0.2-1
- new package built with tito

* Mon Feb 06 2012 Dan McPherson <mmcgrath@redhat.com> 0.1-1
- Initial packaging
