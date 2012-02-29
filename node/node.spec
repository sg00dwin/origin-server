%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Multi-tenant cloud management system node tools
Name:          rhc-node
Version:       0.87.6
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-node-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: ruby
BuildRequires: pam-devel
BuildRequires: libselinux-devel
BuildRequires: gcc-c++
Requires:      rhc-common
Requires:      rhc-selinux >= 0.84.7-1
Requires:      git
Requires:      libcgroup
Requires:      mcollective
Requires:      perl
Requires:      ruby
Requires:      rubygem-open4
Requires:      rubygem-parseconfig
Requires:      rubygem-cloud-sdk-node
Requires:      quota
Requires:      lsof
Requires:      wget
Requires:      oddjob
Requires:      libjpeg-devel
Requires:      libcurl-devel
Requires:      libpng-devel
Requires:      giflib-devel
Requires:      mod_ssl
Requires:      haproxy
Requires:      procmail
Requires(post):   /usr/sbin/semodule
Requires(post):   /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule
Requires(postun): /usr/sbin/semanage


%description
Turns current host into a OpenShift managed node


%prep
%setup -q

%build
for f in **/*.rb
do
  ruby -c $f
done

# Build pam_libra
pwd
cd pam_libra
make
cd -


%install
rm -rf $RPM_BUILD_ROOT

mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libexecdir}
mkdir -p %{buildroot}%{_initddir}
mkdir -p %{buildroot}%{ruby_sitelibdir}
mkdir -p %{buildroot}%{_libexecdir}/li
mkdir -p %{buildroot}/usr/share/selinux/packages
mkdir -p %{buildroot}%{_sysconfdir}/cron.daily/
mkdir -p %{buildroot}%{_sysconfdir}/oddjobd.conf.d/
mkdir -p %{buildroot}%{_sysconfdir}/dbus-1/system.d/
mkdir -p %{buildroot}%{_sysconfdir}/cron.daily/
mkdir -p %{buildroot}%{_sysconfdir}/libra/skel
mkdir -p %{buildroot}/%{_localstatedir}/www/html/
mkdir -p %{buildroot}/%{_sysconfdir}/security/
mkdir -p %{buildroot}%{_localstatedir}/lib/libra
mkdir -p %{buildroot}%{_localstatedir}/run/libra
mkdir -p %{buildroot}%{_localstatedir}/lib/libra/.httpd.d
mkdir -p %{buildroot}%{_localstatedir}/lib/libra/.libra-proxy.d
mkdir -p %{buildroot}/%{_sysconfdir}/httpd/conf.d/
mkdir -p %{buildroot}/lib64/security/
ln -s %{_localstatedir}/lib/libra/.httpd.d/ %{buildroot}/%{_sysconfdir}/httpd/conf.d/libra

cp -r cartridges %{buildroot}%{_libexecdir}/li
cp -r lib %{buildroot}%{_libexecdir}/li
cp -r conf/httpd %{buildroot}%{_sysconfdir}
cp -r conf/libra %{buildroot}%{_sysconfdir}
cp -r facter %{buildroot}%{ruby_sitelibdir}/facter
cp -r mcollective %{buildroot}%{_libexecdir}
cp -r namespace.d %{buildroot}%{_sysconfdir}/security
cp scripts/bin/* %{buildroot}%{_bindir}
cp scripts/init/* %{buildroot}%{_initddir}
cp scripts/libra_tmpwatch.sh %{buildroot}%{_sysconfdir}/cron.daily/libra_tmpwatch.sh
cp conf/oddjob/openshift-restorer.conf %{buildroot}%{_sysconfdir}/dbus-1/system.d/
cp conf/oddjob/oddjobd-restorer.conf %{buildroot}%{_sysconfdir}/oddjobd.conf.d/
cp scripts/restorer.php %{buildroot}/%{_localstatedir}/www/html/
cp pam_libra/pam_libra.so.1  %{buildroot}/lib64/security/pam_libra.so

%clean
rm -rf $RPM_BUILD_ROOT

%post
# mount all desired cgroups under a single root
perl -p -i -e 's:/cgroup/[^\s]+;:/cgroup/all;:; /blkio|cpuset|devices/ && ($_ = "#$_")' /etc/cgconfig.conf
/sbin/restorecon /etc/cgconfig.conf || :
# only restart if it's on
/sbin/chkconfig cgconfig && /sbin/service cgconfig restart >/dev/null 2>&1 || :
/sbin/chkconfig oddjobd on
/sbin/service messagebus restart
/sbin/service oddjobd restart
/sbin/chkconfig --add libra || :
/sbin/chkconfig --add libra-data || :
/sbin/chkconfig --add libra-cgroups || :
/sbin/chkconfig --add libra-tc || :
/sbin/chkconfig --add libra-proxy || :
#/sbin/service mcollective restart > /dev/null 2>&1 || :
/sbin/restorecon /etc/init.d/libra || :
/sbin/restorecon /var/lib/libra || :
/sbin/restorecon /var/run/libra || :
/sbin/restorecon /usr/bin/rhc-cgroup-read || :
/sbin/restorecon /var/lib/libra/.httpd.d/ || :
/sbin/restorecon /var/lib/libra/.libra-proxy.d/ || :
/usr/bin/rhc-restorecon || :
# only enable if cgconfig is
chkconfig cgconfig && /sbin/service libra-cgroups start > /dev/null 2>&1 || :
# only enable if cgconfig is
chkconfig cgconfig && /sbin/service libra-tc start > /dev/null 2>&1 || :
/sbin/service libra-data start > /dev/null 2>&1 || :
echo "/usr/bin/trap-user" >> /etc/shells
/sbin/restorecon /etc/init.d/libra || :
/sbin/restorecon /etc/init.d/mcollective || :
/sbin/restorecon /usr/bin/rhc-restorer* || :
[ $(/usr/sbin/semanage node -l | /bin/grep -c 255.255.255.128) -lt 1000 ] && /usr/bin/rhc-ip-prep.sh || :
/sbin/chkconfig --add libra-watchman || :

# Ensure the default users have a more restricted shell then normal.
#semanage login -m -s guest_u __default__ || :

# If /etc/httpd/conf.d/libra is a dir, make it a symlink
if [[ -d "/etc/httpd/conf.d/libra.bak" && -L "/etc/httpd/conf.d/libra" ]]
then
    mv /etc/httpd/conf.d/libra.bak/* /var/lib/libra/.httpd.d/
    # not forced to prevent data loss
    rmdir /etc/httpd/conf.d/libra.bak
fi

if ! [ -f /var/lib/libra/.libra-proxy.d/libra-proxy.cfg ]; then
   cp /etc/libra/libra-proxy.cfg /var/lib/libra/.libra-proxy.d/libra-proxy.cfg
   restorecon /var/lib/libra/.libra-proxy.d/libra-proxy.cfg || :
fi


%preun
if [ "$1" -eq "0" ]; then
    /sbin/service libra-tc stop > /dev/null 2>&1 || :
    /sbin/service libra-cgroups stop > /dev/null 2>&1 || :
    /sbin/service libra-watchman stop > /dev/null 2>&1 || :
    /sbin/chkconfig --del libra-tc || :
    /sbin/chkconfig --del libra-cgroups || :
    /sbin/chkconfig --del libra-data || :
    /sbin/chkconfig --del libra || :
    /sbin/chkconfig --del libra-proxy || :
    /sbin/chkconfig --del libra-watchman || :
    /usr/sbin/semodule -r libra
    sed -i -e '\:/usr/bin/trap-user:d' /etc/shells
fi

%postun
if [ "$1" -eq 0 ]; then
    /sbin/service mcollective restart > /dev/null 2>&1 || :
fi
#/usr/sbin/semodule -r libra

%pre

if [[ -d "/etc/httpd/conf.d/libra" && ! -L "/etc/httpd/conf.d/libra" ]]
then
    mv /etc/httpd/conf.d/libra/ /etc/httpd/conf.d/libra.bak/
fi

%triggerin -- haproxy
/sbin/service libra-proxy condrestart

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/*
%attr(0750,-,-) %{_libexecdir}/mcollective/update_yaml.rb
%attr(0640,-,-) %{ruby_sitelibdir}/facter/libra.rb
%attr(0750,-,-) %{_initddir}/libra
%attr(0750,-,-) %{_initddir}/libra-data
%attr(0750,-,-) %{_initddir}/libra-cgroups
%attr(0750,-,-) %{_initddir}/libra-tc
%attr(0750,-,-) %{_initddir}/libra-proxy
%attr(0750,-,-) %{_initddir}/libra-watchman
%attr(0755,-,-) %{_bindir}/trap-user
%attr(0750,-,-) %{_bindir}/rhc-ip-prep.sh
%attr(0750,-,-) %{_bindir}/rhc-iptables.sh
%attr(0750,-,-) %{_bindir}/rhc-restorecon
%attr(0750,-,-) %{_bindir}/rhc-init-quota
%attr(0750,-,-) %{_bindir}/rhc-list-stale
%attr(0750,-,-) %{_bindir}/rhc-idler
%attr(0750,-,-) %{_bindir}/rhc-last-access
%attr(0750,-,-) %{_bindir}/rhc-app-idle
%attr(0750,-,-) %{_bindir}/rhc-autoidler
%attr(0750,-,-) %{_bindir}/rhc-idler-stats
%attr(0750,-,-) %{_bindir}/rhc-restorer
%attr(0750,-,apache) %{_bindir}/rhc-restorer-wrapper.sh
%attr(0750,-,-) %{_bindir}/ec2-prep.sh
%attr(0750,-,-) %{_bindir}/remount-secure.sh
%attr(0755,-,-) %{_bindir}/rhc-cgroup-read
%dir %attr(0751,root,root) %{_localstatedir}/lib/libra
%dir %attr(0750,root,root) %{_localstatedir}/lib/libra/.httpd.d
%dir %attr(0750,root,root) %{_localstatedir}/lib/libra/.libra-proxy.d
%dir %attr(0700,root,root) %{_localstatedir}/run/libra
%dir %attr(0755,root,root) %{_libexecdir}/li/cartridges/abstract-httpd/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract-httpd/info/hooks/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract-httpd/info/bin/
#%{_libexecdir}/li/cartridges/abstract-httpd/info
%dir %attr(0755,root,root) %{_libexecdir}/li/cartridges/abstract/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract/info/hooks/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract/info/bin/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract/info/lib/
%attr(0755,-,-) %{_libexecdir}/li/lib/
#%{_libexecdir}/li/cartridges/abstract/info
%attr(0750,-,-) %{_bindir}/rhc-accept-node
%attr(0750,-,-) %{_bindir}/rhc-idle-apps
%attr(0755,-,-) %{_bindir}/rhc-list-ports
%attr(0750,-,-) %{_bindir}/rhc-node-account
%attr(0750,-,-) %{_bindir}/rhc-node-application
%attr(0750,-,-) %{_bindir}/rhc-watchman
%attr(0755,-,-) %{_bindir}/rhcsh
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/oddjobd.conf.d/oddjobd-restorer.conf
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/dbus-1/system.d/openshift-restorer.conf
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/libra/node.conf
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/libra/libra-proxy.cfg
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/libra/resource_limits.con*
%attr(0750,-,-) %config(noreplace) %{_sysconfdir}/cron.daily/libra_tmpwatch.sh
%attr(0644,-,-) %config(noreplace) %{_sysconfdir}/security/namespace.d/*
%{_localstatedir}/www/html/restorer.php
%attr(0750,root,root) %config(noreplace) %{_sysconfdir}/httpd/conf.d/000000_default.conf
%attr(0640,root,root) %{_sysconfdir}/httpd/conf.d/libra
%dir %attr(0755,root,root) %{_sysconfdir}/libra/skel
/lib64/security/pam_libra.so

%changelog
* Tue Feb 28 2012 Dan McPherson <dmcphers@redhat.com> 0.87.6-1
- rework migration of git to not stop/start/redeploy (dmcphers@redhat.com)
- dont pre/post move for same uid (dmcphers@redhat.com)
- some cleanup of http -C Include (dmcphers@redhat.com)
- Improper method of counting length of bash array (rmillner@redhat.com)
- Rewrote to deal better with errors from the proxy init script
  (rmillner@redhat.com)
- No longer needed. (rmillner@redhat.com)
- ~/.state tracking feature (jhonce@redhat.com)
- remove the spaces from the assignment and create tmp dir (johnp@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.5-1
- Adds apptegic call to report idled apps. (mpatel@redhat.com)
- add link to rails production.log (dmcphers@redhat.com)
- specify full path to the git deploy script (johnp@redhat.com)
- add submodule support testsing and move to app tmp dir instead of user tmp
  (johnp@redhat.com)
- add support for submodules when deploying to repo directory
  (johnp@redhat.com)
- cleanup all the old command usage in help and messages (dmcphers@redhat.com)

* Sun Feb 26 2012 Dan McPherson <dmcphers@redhat.com> 0.87.4-1
- finishing standalone.xml migration (dmcphers@redhat.com)
- initial jboss migration and sync fixes (dmcphers@redhat.com)

* Sat Feb 25 2012 Dan McPherson <dmcphers@redhat.com> 0.87.3-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mpatel@redhat.com)
- Adding the idling related scripts. (mpatel@redhat.com)
- Don't run this in a subshell (rmillner@redhat.com)
- Update show-port hook and re-add function. (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mpatel@redhat.com)
- Adds script to check whether a particular app is idle or not.
  (mpatel@redhat.com)
- Blanket purge proxy ports on application teardown. (rmillner@redhat.com)
- Forgot to include uuid in calls (rmillner@redhat.com)
- Use the libra-proxy configuration rather than variables to spot conflict and
  allocation. Switch to machine readable output. Simplify the proxy calls to
  take one target at a time (what most cartridges do anyway). Use cartridge
  specific variables. (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Adds rhc-last-access to node.spec. (mpatel@redhat.com)
- Adds rhc-last-access script. (mpatel@redhat.com)
- Add showproxy command (rmillner@redhat.com)
- adding logger to rhc-idler (mmcgrath@redhat.com)
- Allow rhc-list-stale to take an arbitrary number of days
  (mmcgrath@redhat.com)
- Add additional guards in case jboss has been created but not started
  (jhonce@redhat.com)
- Update cartridge configure hooks to load git repo from remote URL Add REST
  API to create application from template Moved application template
  models/controller to cloud-sdk (kraman@gmail.com)
- comma is also a valid json character... fixing mcollective args validation
  (rchopra@redhat.com)
- quotes are valid characters in json (rchopra@redhat.com)
- fix validate args for mcollective calls as we are sending json strings over
  now (rchopra@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.87.2-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mpatel@redhat.com)
- Adds idle app script. (mpatel@redhat.com)
- checkpoint 3 - horizontal scaling, minor fixes, connector hook for haproxy
  not complete (rchopra@redhat.com)
- Add show-proxy call. (rmillner@redhat.com)
- Move expose, conceal, and show functions to the network include script.
  Accept multiple targets for port proxy functions.  The expose-port hook is
  all-or-nothing: it will either add all proxy ports requested or fail without
  adding any.  Add show port hook.  Harmonize output from all hooks so it
  follows same format for regexps that parse the output. (rmillner@redhat.com)
- Added checks for missing entries in .env directory (jhonce@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Adding a ulimit so selinux will complete" (mmcgrath@redhat.com)
- Bug 795654 (dmcphers@redhat.com)
- use var_tmp_t (mmcgrath@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- change to use lines rather than split (dmcphers@redhat.com)
- US1848 -- implement mysql "passwordless" access. (ramr@redhat.com)
- Merge branch 'US1401' (jhonce@redhat.com)
- Added capture of exceptions in event loop + retry count Added syslog warning
  to debug BZ795331 (jhonce@redhat.com)
- add migration for jenkins security (dmcphers@redhat.com)
- switch epel rpm (dmcphers@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.87.1-1
- bump spec numbers (dmcphers@redhat.com)
- rhc-idler: changed it to not try to idle already idled apps
  (twiest@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.86.7-1
- Bug 791044: Missing space caused sed expression to match till the end of the
  file. (rmillner@redhat.com)

* Wed Feb 15 2012 Dan McPherson <dmcphers@redhat.com> 0.86.6-1
- Fixed bad method name (jhonce@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Port ranges incorrect (rmillner@redhat.com)
- BZ790622 (jhonce@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.5-1
- move export of mcs_level (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- The expose-port, conceal-port and system-messages calls fell out while
  rolling back patches. (rmillner@redhat.com)
- Fix bug - need to pass all parameters down rather than just the first.
  (ramr@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Add proxy script
  calls to the API" (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Back-out selectable targets. (rmillner@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.4-1
- start Watchman services (jhonce@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- increase active apps to 50 (mmcgrath@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.3-1
- Added ability to specify a specific proxy to tear down. (rmillner@redhat.com)
- Fixed bug where only the first port was used. Added ability to call with a
  target address which gets verified to see if its in the user's range.
  (rmillner@redhat.com)
- add back capacity and restrict remove node to 0 capacity nodes
  (dmcphers@redhat.com)
- US1401 Watchman Service (jhonce@redhat.com)
- bug 722828 (bdecoste@gmail.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (bdecoste@gmail.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (bdecoste@gmail.com)
- bug 722828 (bdecoste@gmail.com)

* Sat Feb 11 2012 Dan McPherson <dmcphers@redhat.com> 0.86.2-1
- move the selinux logic out of abstract carts entirely (dmcphers@redhat.com)
- get move working again and add quota support (dmcphers@redhat.com)
- revert back file from accidental commit (dmcphers@redhat.com)
- Add proxy script calls to the API (rmillner@redhat.com)
- add load node conf to remove httpd proxy (dmcphers@redhat.com)
- more abstracting out selinux (dmcphers@redhat.com)
- fix typo (dmcphers@redhat.com)
- better name consistency (dmcphers@redhat.com)
- first pass at splitting out selinux logic (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Cosmetic cleanup. (rmillner@redhat.com)
- The haproxy restart test failed if haproxy had been re-installed or upgraded.
  Also, trigger restart of the proxy if haproxy is upgraded.
  (rmillner@redhat.com)
- bug 722828 (wdecoste@localhost.localdomain)
- Hook to fix the proxy back-end if it diverges from the app configuration.
  (rmillner@redhat.com)
- Adding DNS name to port exposure (mmcgrath@redhat.com)
- Creating models for descriptor Fixing manifest files Added command to list
  installed cartridges and get descriptors (kraman@gmail.com)
- Re-do proxy setting so that I can do additions and deletions for an app in at
  most one restart. (rmillner@redhat.com)
- Quiet grep (rmillner@redhat.com)
- Process several proxies/ports on one invocation efficiently.
  (rmillner@redhat.com)
- Consolidate the lock+restart wrapper and only restart if the configuration
  actually changed. (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Move libra-proxy config file to /var/lib/libra/.libra-proxy.d
  (rmillner@redhat.com)
- Merge branch 'master' into haproxy (mmcgrath@redhat.com)
- Adding expose-port and conceal-port (mmcgrath@redhat.com)
- Adding expose and conceal port (mmcgrath@redhat.com)
- change status to use normal client_result instead of special handling
  (dmcphers@redhat.com)
- Merge branch 'master' into haproxy (mmcgrath@redhat.com)
- Merge branch 'master' into haproxy (mmcgrath@redhat.com)
- That method would fail if haproxy is being run for another service.  Test the
  exit code of the takeover process instead. (rmillner@redhat.com)
- Edge case where the new process fails to take over ports belonging to the old
  one. (rmillner@redhat.com)
- The output of listproxies can be fed back in as proxy definitions.
  (rmillner@redhat.com)
- Fixed artifact from copying command line (rmillner@redhat.com)
- List proxies, add and remove proxies command.  Included locking and wait for
  state transition to prevent haproxy from getting stepped on.
  (rmillner@redhat.com)
- Add procmail for lockfile command (rmillner@redhat.com)
- Add a boot-time libra-proxy service (rmillner@redhat.com)
- Adding open_ports script (presently requires root) (mmcgrath@redhat.com)
- syntax cleanup (dmcphers@redhat.com)
- removing basename and app_name as they are not used (mmcgrath@redhat.com)
- capacity should ignore symlinks (mmcgrath@redhat.com)
- Bug 787994 (dmcphers@redhat.com)
- Simplify based on the current proxy plan.  Input rules to allow port proxy.
  (rmillner@redhat.com)
- Bug 787882 (dmcphers@redhat.com)
- make actions and cdk commands match (dmcphers@redhat.com)
- increase std and large gear restrictions (dmcphers@redhat.com)
- keep apps stopped or idled on move (dmcphers@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.86.1-1
- bump spec numbers (dmcphers@redhat.com)
- adding mod_ssl (mmcgrath@redhat.com)
- Allow users in the wheel group to login as unconfined_t otherwize libra_t
  (dwalsh@redhat.com)

* Wed Feb 01 2012 Dan McPherson <dmcphers@redhat.com> 0.85.20-1
- Bug 786371 (dmcphers@redhat.com)

* Wed Feb 01 2012 Dan McPherson <dmcphers@redhat.com> 0.85.19-1
- fix selinux issues with move (dmcphers@redhat.com)

* Tue Jan 31 2012 Dan McPherson <dmcphers@redhat.com> 0.85.18-1
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Redo commit 92024243d1dc321b81022722ad0c804da9b49060 -- issues cherry
  picking. Switching to the popen4 extension that closes fd's - popen leaves
  inherited file descriptors open per the POSIX spec. This is not good for
  MCollective's usage as any command executed will inherit access to it's qpid
  socket.  This patch stops that behavior. (ramr@redhat.com)

* Tue Jan 31 2012 Dan McPherson <dmcphers@redhat.com> 0.85.17-1
- better message (dmcphers@redhat.com)
- make stop and start order more predictable (dmcphers@redhat.com)
- use 755 to be consistent (dmcphers@redhat.com)
- take back _ctl.sh (dmcphers@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.85.16-1
- fixing trapuser (mmcgrath@redhat.com)
- Re-enabling 127.0.0.1 ban (mmcgrath@redhat.com)
- migration changes (dmcphers@redhat.com)
- handle already reserved uids (dmcphers@redhat.com)
- correcting node.spec with description (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- rename li-controller to cloud-sdk-node (dmcphers@redhat.com)
- Adding pam_libra dep (mmcgrath@redhat.com)
- Add and remove capacity from a district (dmcphers@redhat.com)
- fixing php type (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Migrating rack/ruby wsgi/python (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Include examples as a guide, some shuffling. (rmillner@redhat.com)
- Nat table entries, fix INPUT rule to match DNAT packets, multiport module not
  required. (rmillner@redhat.com)
- allow install from source plus some districts changes (dmcphers@redhat.com)
- Configuration starts with an IP address and netmask rather than integers.
  (rmillner@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.15-1
- adding base 2.0.4 migration (dmcphers@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.14-1
- Assumptions about how uid would work were wrong.  That's now a dynamic table.
  Add tables for input filtering and DNAT. (rmillner@redhat.com)

* Mon Jan 23 2012 Dan McPherson <dmcphers@redhat.com> 0.85.13-1
- Use additional table to simplify rules a bit.  Bugfixes.
  (rmillner@redhat.com)
- Not able to solve this with selinux.  Use iptables instead.
  (rmillner@redhat.com)
- Try libra_port_t (rmillner@redhat.com)

* Fri Jan 20 2012 Dan McPherson <dmcphers@redhat.com> 0.85.12-1
- getting to the real districts mongo impl (dmcphers@redhat.com)

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.11-1
- Fix pam_libra to user the system_r role rather then unconfined_r, also add
  better errno reporting (dwalsh@redhat.com)

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.10-1
- adding libselinux-devel to the requires list

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.9-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Added pam_libra (mmcgrath@redhat.com)
- Temporary commit to build (mmcgrath@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.8-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Move libra-datastore to devenv.spec (rpenta@redhat.com)

* Wed Jan 18 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.7-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- mongo datastore fixes (rpenta@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.85.6-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- configure/start mongod service for new devenv launch (rpenta@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.85.5-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (bdecoste@gmail.com)
- rollback rack chances for threaddump (bdecoste@gmail.com)
- working on base migration (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (bdecoste@gmail.com)
- replace OPENSHIFT_APP_DIR in httpd start (bdecoste@gmail.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.4-1
- remove broker gem refs for threaddump (bdecoste@gmail.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- implementation of user story 1734 : max_active_apps metric. Currently the
  value is set to 100. Also note, that now, this value will influence the
  capacity of nodes. (rchopra@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.3-1
- US1667: threaddump for rack (wdecoste@localhost.localdomain)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- move district lookup to /etc/libra/district.conf (dmcphers@redhat.com)
- districts (work in progress) (dmcphers@redhat.com)
