%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Multi-tenant cloud management system node tools
Name:          rhc-node
Version: 0.96.13
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
Requires:      rubygem-stickshift-node
Requires:      rubygem-systemu
Requires:      stickshift-abstract
Requires:      mcollective-qpid-plugin
Requires:      stickshift-mcollective-agent
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
Requires:      libevent
Requires:      libevent-devel
Requires(post):   /usr/sbin/semodule
Requires(post):   /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule
Requires(postun): /usr/sbin/semanage


%description
Turns current host into a OpenShift managed node


%prep
%setup -q

%build

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
mkdir -p %{buildroot}%{_libexecdir}/stickshift
mkdir -p %{buildroot}/usr/share/selinux/packages
mkdir -p %{buildroot}%{_sysconfdir}/cron.daily/
mkdir -p %{buildroot}%{_sysconfdir}/oddjobd.conf.d/
mkdir -p %{buildroot}%{_sysconfdir}/dbus-1/system.d/
mkdir -p %{buildroot}%{_sysconfdir}/cron.daily/
mkdir -p %{buildroot}%{_sysconfdir}/stickshift/skel
mkdir -p %{buildroot}/%{_localstatedir}/www/html/
mkdir -p %{buildroot}/%{_sysconfdir}/security/
mkdir -p %{buildroot}%{_localstatedir}/lib/stickshift
mkdir -p %{buildroot}%{_localstatedir}/run/stickshift
mkdir -p %{buildroot}%{_localstatedir}/lib/stickshift/.httpd.d
mkdir -p %{buildroot}%{_localstatedir}/lib/stickshift/.stickshift-proxy.d
mkdir -p %{buildroot}/%{_sysconfdir}/httpd/conf.d/
mkdir -p %{buildroot}/lib64/security/
# ln -s %{_localstatedir}/lib/stickshift/.httpd.d/ %{buildroot}/%{_sysconfdir}/httpd/conf.d/stickshift

cp -r lib %{buildroot}%{_libexecdir}/stickshift
cp -r conf/httpd %{buildroot}%{_sysconfdir}
cp -r conf/stickshift %{buildroot}%{_sysconfdir}
cp -r mcollective %{buildroot}%{_libexecdir}
cp -r namespace.d %{buildroot}%{_sysconfdir}/security
cp scripts/bin/* %{buildroot}%{_bindir}
cp scripts/init/* %{buildroot}%{_initddir}
cp scripts/stickshift_tmpwatch.sh %{buildroot}%{_sysconfdir}/cron.daily/stickshift_tmpwatch.sh
cp conf/oddjob/openshift-restorer.conf %{buildroot}%{_sysconfdir}/dbus-1/system.d/
cp conf/oddjob/oddjobd-restorer.conf %{buildroot}%{_sysconfdir}/oddjobd.conf.d/
cp scripts/restorer.php %{buildroot}/%{_localstatedir}/www/html/
cp pam_libra/pam_libra.so.1  %{buildroot}/lib64/security/pam_libra.so

%clean
rm -rf $RPM_BUILD_ROOT

%post
cp -f /etc/stickshift/stickshift-node.conf.libra /etc/stickshift/stickshift-node.conf
restorecon /var/lib/stickshift/stickshift-node.conf || :

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
#/sbin/service mcollective restart > /dev/null 2>&1 || :
/sbin/restorecon /etc/init.d/libra || :
/sbin/restorecon /var/lib/stickshift || :
/sbin/restorecon /var/run/stickshift || :
/sbin/restorecon /usr/bin/rhc-cgroup-read || :
/sbin/restorecon /var/lib/stickshift/.httpd.d/ || :
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
if [[ -d "/etc/httpd/conf.d/stickshift.bak" && -L "/etc/httpd/conf.d/stickshift" ]]
then
    mv /etc/httpd/conf.d/stickshift.bak/* /var/lib/stickshift/.httpd.d/
    # not forced to prevent data loss
    rmdir /etc/httpd/conf.d/stickshift.bak
fi

# To workaround mcollective 2.0 monkey patch to tmpdir
chmod o+w /tmp

# Enable proxy and fix if the config file is missing
/sbin/chkconfig --add stickshift-proxy || :
if ! [ -f /var/lib/stickshift/.stickshift-proxy.d/stickshift-proxy.cfg ]; then
   cp /etc/stickshift/stickshift-proxy.cfg /var/lib/stickshift/.stickshift-proxy.d/stickshift-proxy.cfg
   restorecon /var/lib/stickshift/.stickshift-proxy.d/stickshift-proxy.cfg || :
fi
/sbin/restorecon /var/lib/stickshift/.stickshift-proxy.d/ || :
/sbin/service stickshift-proxy condrestart || :



%triggerin -- rubygem-stickshift-node

cp -f /etc/stickshift/stickshift-node.conf.libra /etc/stickshift/stickshift-node.conf
restorecon /var/lib/stickshift/stickshift-node.conf || :
/sbin/service libra-data start > /dev/null 2>&1 || :


%preun
if [ "$1" -eq "0" ]; then
    /sbin/service libra-tc stop > /dev/null 2>&1 || :
    /sbin/service libra-cgroups stop > /dev/null 2>&1 || :
    /sbin/service libra-watchman stop > /dev/null 2>&1 || :
    /sbin/chkconfig --del libra-tc || :
    /sbin/chkconfig --del libra-cgroups || :
    /sbin/chkconfig --del libra-data || :
    /sbin/chkconfig --del libra || :
    /sbin/chkconfig --del stickshift-proxy || :
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

if [[ -d "/etc/httpd/conf.d/stickshift" && ! -L "/etc/httpd/conf.d/stickshift" ]]
then
    mv /etc/httpd/conf.d/stickshift/ /etc/httpd/conf.d/stickshift.bak/
fi

%triggerin -- haproxy
/sbin/service stickshift-proxy condrestart

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/*
%attr(0750,-,-) %{_initddir}/libra
%attr(0750,-,-) %{_initddir}/libra-data
%attr(0750,-,-) %{_initddir}/libra-cgroups
%attr(0750,-,-) %{_initddir}/libra-tc
%attr(0750,-,-) %{_initddir}/stickshift-proxy
%attr(0750,-,-) %{_initddir}/libra-watchman
%attr(0755,-,-) %{_bindir}/trap-user
%attr(0750,-,-) %{_bindir}/rhc-ip-prep.sh
%attr(0750,-,-) %{_bindir}/rhc-iptables.sh
%attr(0750,-,-) %{_bindir}/rhc-mcollective-log-profile
%attr(0750,-,-) %{_bindir}/rhc-profiler-merge-report
%attr(0750,-,-) %{_bindir}/rhc-restorecon
%attr(0750,-,-) %{_bindir}/rhc-init-quota
%attr(0750,-,-) %{_bindir}/rhc-list-stale
%attr(0750,-,-) %{_bindir}/rhc-app-gear-xlate
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
%dir %attr(0751,root,root) %{_localstatedir}/lib/stickshift
%dir %attr(0750,root,root) %{_localstatedir}/lib/stickshift/.httpd.d
%dir %attr(0750,root,root) %{_localstatedir}/lib/stickshift/.stickshift-proxy.d
%dir %attr(0700,root,root) %{_localstatedir}/run/stickshift
#%dir %attr(0755,root,root) %{_libexecdir}/stickshift/cartridges/abstract-httpd/
#%attr(0750,-,-) %{_libexecdir}/stickshift/cartridges/abstract-httpd/info/hooks/
#%attr(0755,-,-) %{_libexecdir}/stickshift/cartridges/abstract-httpd/info/bin/
##%{_libexecdir}/stickshift/cartridges/abstract-httpd/info
#%dir %attr(0755,root,root) %{_libexecdir}/stickshift/cartridges/abstract/
#%attr(0750,-,-) %{_libexecdir}/stickshift/cartridges/abstract/info/hooks/
#%attr(0755,-,-) %{_libexecdir}/stickshift/cartridges/abstract/info/bin/
#%attr(0755,-,-) %{_libexecdir}/stickshift/cartridges/abstract/info/lib/
#%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract/info/connection-hooks/
%attr(0755,-,-) %{_libexecdir}/stickshift/lib/
#%{_libexecdir}/stickshift/cartridges/abstract/info
%attr(0750,-,-) %{_bindir}/rhc-accept-node
%attr(0750,-,-) %{_bindir}/rhc-accept-devenv
%attr(0755,-,-) %{_bindir}/rhc-list-ports
%attr(0750,-,-) %{_bindir}/rhc-node-account
%attr(0750,-,-) %{_bindir}/rhc-node-application
%attr(0750,-,-) %{_bindir}/rhc-watchman
%attr(0755,-,-) %{_bindir}/rhcsh
%attr(0700,-,-) %{_bindir}/migration-symlink-as-user
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/oddjobd.conf.d/oddjobd-restorer.conf
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/dbus-1/system.d/openshift-restorer.conf
%attr(0644,-,-) %config(noreplace) %{_sysconfdir}/stickshift/stickshift-node.conf.libra
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/stickshift/stickshift-proxy.cfg
%attr(0644,-,-) %config(noreplace) %{_sysconfdir}/stickshift/resource_limits.con*
%attr(0750,-,-) %config(noreplace) %{_sysconfdir}/cron.daily/stickshift_tmpwatch.sh
%attr(0644,-,-) %config(noreplace) %{_sysconfdir}/security/namespace.d/*
%{_localstatedir}/www/html/restorer.php
%attr(0750,root,root) %config(noreplace) %{_sysconfdir}/httpd/conf.d/000000_default.conf
#%attr(0640,root,root) %{_sysconfdir}/httpd/conf.d/stickshift
%dir %attr(0755,root,root) %{_sysconfdir}/stickshift/skel
/lib64/security/pam_libra.so

%changelog
* Mon Aug 06 2012 Adam Miller <admiller@redhat.com> 0.96.13-1
- remove *.war.* from deployments (bdecoste@gmail.com)

* Fri Aug 03 2012 Adam Miller <admiller@redhat.com> 0.96.12-1
- remove *.war.* from deployments (bdecoste@gmail.com)

* Thu Aug 02 2012 Adam Miller <admiller@redhat.com> 0.96.11-1
- Filter for directories (rmillner@redhat.com)

* Wed Aug 01 2012 Adam Miller <admiller@redhat.com> 0.96.10-1
- Merge branch 'master' of https://github.com/openshift/li (bdecoste@gmail.com)
- migration for BZ844267 (bdecoste@gmail.com)
- BZ 844948: Medium gear gets same quota as small and large.
  (rmillner@redhat.com)

* Tue Jul 31 2012 Dan McPherson <dmcphers@redhat.com> 0.96.9-1
- Move tc output to global and examine the quota output to ensure its really
  enforcing. (rmillner@redhat.com)

* Tue Jul 31 2012 Adam Miller <admiller@redhat.com> 0.96.8-1
- Cleaning up m-collective from li repo (kraman@gmail.com)

* Mon Jul 30 2012 Dan McPherson <dmcphers@redhat.com> 0.96.7-1
- Ruby version of rhc-accept-node from BZ 843106 (rmillner@redhat.com)

* Thu Jul 26 2012 Dan McPherson <dmcphers@redhat.com> 0.96.6-1
- Stand-alone mysql or mongodb gears disable stale detection.
  (rmillner@redhat.com)
- Merge pull request #90 from tdawson/mirror (dmcphers@redhat.com)
- replace mirror.stg and prod with mirror.ops (tdawson@redhat.com)

* Tue Jul 24 2012 Adam Miller <admiller@redhat.com> 0.96.5-1
- Add pre and post destroy calls on gear destruction and move unobfuscate and
  stickshift-proxy out of cartridge hooks and into node. (rmillner@redhat.com)

* Fri Jul 20 2012 Adam Miller <admiller@redhat.com> 0.96.4-1
- Merge branch 'master' of github.com:openshift/li (mmcgrath@redhat.com)
- made init script more efficient (mmcgrath@redhat.com)

* Thu Jul 19 2012 Adam Miller <admiller@redhat.com> 0.96.3-1
- add rhc-accept-devenv (dmcphers@redhat.com)

* Fri Jul 13 2012 Adam Miller <admiller@redhat.com> 0.96.2-1
- Merge pull request #71 from tkramer-rh/dev/tkramer/bug/831325
  (admiller@redhat.com)
- Merge pull request #62 from jwhonce/BZ837066 (admiller@redhat.com)
- Security - BZ831325 - Block random high ports from binding in the 127.0.0.1
  address space. (tkramer@redhat.com)
- update migration to 2.0.15 and add better config for migration
  (dmcphers@redhat.com)
- Corrected check period (jhonce@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.96.1-1
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Tue Jul 10 2012 Adam Miller <admiller@redhat.com> 0.95.7-1
- Remove unused methods from ddl. (mpatel@redhat.com)

* Thu Jul 05 2012 Adam Miller <admiller@redhat.com> 0.95.6-1
- Merge pull request #20 from jwhonce/BZ837066 (mmcgrath+openshift@redhat.com)
- BZ837066 watchman inefficient (jhonce@redhat.com)

* Tue Jul 03 2012 Adam Miller <admiller@redhat.com> 0.95.5-1
- Fix for bugz 837424 - typeless gears migration. (ramr@redhat.com)

* Tue Jul 03 2012 Adam Miller <admiller@redhat.com> 0.95.4-1
- Taking out duplicate link. (mpatel@redhat.com)
- Add missing systemu dependency. (mpatel@redhat.com)
- Migration for bugz 837130. (ramr@redhat.com)
- Remove duplicate file. (mpatel@redhat.com)
- Add new dependencies. (mpatel@redhat.com)
- Fixes. (mpatel@redhat.com)
- WIP changes to support mcollective 2.0. (mpatel@redhat.com)

* Mon Jul 02 2012 Adam Miller <admiller@redhat.com> 0.95.3-1
- Merge pull request #7 from rmillner/dev/rmillner/bug/827817
  (rpenta@redhat.com)
- update migration for 2.0.14 (dmcphers@redhat.com)
- BZ 827817: Add interactive shell for PostgreSQL. (rmillner@redhat.com)
- Bug 828126 (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.95.2-1
- new package built with tito

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 0.95.1-1
- bump_minor_versions for sprint 14 (admiller@redhat.com)
- BZ834126 (jhonce@redhat.com)

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 0.94.10-1
- BZ 830286: Missing -n option (rmillner@redhat.com)

* Fri Jun 15 2012 Adam Miller <admiller@redhat.com> 0.94.9-1
- BZ832261: Order app start scripts using the same logic as the start function
  in util.  Explicitly reverse that order on stop. (rmillner@redhat.com)

* Thu Jun 14 2012 Adam Miller <admiller@redhat.com> 0.94.8-1
- BZ829826 additionally made some performance enhancements (jhonce@redhat.com)
- Migration for HAProxy stats socket file. (mpatel@redhat.com)

* Wed Jun 13 2012 Adam Miller <admiller@redhat.com> 0.94.7-1
- BZ 830286.  Defer restarting httpd until the end of a set of applications.
  (rmillner@redhat.com)
- BZ827575.  Also allow existing applications to specify foreign channels in
  deplist.txt. (rmillner@redhat.com)
- BZ806468 Relocate/Rename district.conf (jhonce@redhat.com)
- Modified name to c9 + change limits. (ramr@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 0.94.6-1
- Add cloud9.io high density node profile. (ramr@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 0.94.5-1
- Security - changed URL in rhcsh to point to proper legal page
  (tkramer@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> 0.94.4-1
- Security - added legal login banner to OpenShift shell (tkramer@redhat.com)

* Fri Jun 08 2012 Adam Miller <admiller@redhat.com> 0.94.3-1
- Proxy init script cleanup. (rmillner@redhat.com)
- Fix glob to find git directories (jhonce@redhat.com)
- Bug 806468 /etc/stickshift/district.conf should be put under /var
  (jhonce@redhat.com)
- The exta rules are expensive and unnecessary; we will expand the ranger later
  if its needed. (rmillner@redhat.com)
- Needed a larger range allocated for iptables rules.  Also, the port to uid
  mapping is no longer trivial. (rmillner@redhat.com)

* Mon Jun 04 2012 Adam Miller <admiller@redhat.com> 0.94.2-1
- update migration for 2.0.13 and fix gear dns fixup with scaled apps
  (dmcphers@redhat.com)
- Improved exception handling (jhonce@redhat.com)
- fix facter loop (jhonce@redhat.com)

* Fri Jun 01 2012 Adam Miller <admiller@redhat.com> 0.94.1-1
- bumping spec versions (admiller@redhat.com)
- restore embedded cartridges when migrating (jhonce@redhat.com)
- Fix for bugz 827564. Only list scaled gears if gear registry exists.
  (ramr@redhat.com)

* Wed May 30 2012 Adam Miller <admiller@redhat.com> 0.93.13-1
- Add support for http alias (jhonce@redhat.com)
- Fix bugz 825792 -- OPENSHIFT_{DATA,REPO}_DIR needs a trailing /.
  (ramr@redhat.com)
- Typeless gears migration fixes for new app-root updates. (ramr@redhat.com)
- Merge branch 'US2109' (rmillner@redhat.com)
- Fix to make inline ss calls multithreaded. (mpatel@redhat.com)
- Fix migrate rerun issues - check runtime/repo instead of runtime.
  (ramr@redhat.com)
- Bug fix to handle case when migrate is rerun. (ramr@redhat.com)
- Migrate work for typeless gears. (ramr@redhat.com)
- Merge branch 'master' into US2109 (rmillner@redhat.com)
- TA2182 Latest location for .state file (jhonce@redhat.com)

* Tue May 29 2012 Adam Miller <admiller@redhat.com> 0.93.12-1
- Add migration code for previously created scalable apps - bugz 825077.
  (ramr@redhat.com)
- Fix for bugz 825077 - mysql added to a scalable app is not accessible via
  environment variables. OPENSHIFT_DB_HOST is now set correctly.
  (ramr@redhat.com)

* Tue May 29 2012 Adam Miller <admiller@redhat.com> 0.93.11-1
- Bug 820223 820338 820325 (dmcphers@redhat.com)
- re-introduce ~/data in typeless gears (jhonce@redhat.com)
- Security - Moved the disable of binding of ports on the real 10. address from
  devenv.spec to rhc-ip-prep.sh so that it can make it into STG for testing
  (tkramer@redhat.com)

* Fri May 25 2012 Dan McPherson <dmcphers@redhat.com> 0.93.10-1
- US2109 Migration (jhonce@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- BZ 825124, had the wrong variable name. (rmillner@redhat.com)

* Fri May 25 2012 Adam Miller <admiller@redhat.com> 0.93.9-1
- Bug 825207: Do not chown on nonexistent .state file (jhonce@redhat.com)

* Thu May 24 2012 Adam Miller <admiller@redhat.com> 0.93.8-1
- more efficient cgroup disabling method (mmcgrath@redhat.com)

* Thu May 24 2012 Adam Miller <admiller@redhat.com> 0.93.7-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- US2307 (bdecoste@gmail.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- cleaning up whitespace, no longer killing apps on cgroup stop, adding cgroup
  bits (mmcgrath@redhat.com)

* Wed May 23 2012 Adam Miller <admiller@redhat.com> 0.93.6-1
- [mpatel+ramr] Fix issues where app_name is not the same as gear_name - fixups
  for typeless gears. (ramr@redhat.com)
- BZ824546 move nurture notification (jhonce@redhat.com)
- fix for BZ: 824135 (mmcgrath@redhat.com)

* Tue May 22 2012 Adam Miller <admiller@redhat.com> 0.93.5-1
- ITERS was not incrementing.  This would run for ever if semodule call was
  failing. (rmillner@redhat.com)

* Tue May 22 2012 Dan McPherson <dmcphers@redhat.com> 0.93.4-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Merge branch 'US2109' of ssh://git1.ops.rhcloud.com/srv/git/li into US2109
  (rmillner@redhat.com)
- migrate http proxy config (jhonce@redhat.com)
- Merge branch 'master' into US2109 (rmillner@redhat.com)
- Merge branch 'master' into US2109 (rmillner@redhat.com)
- Merge branch 'master' into US2109 (jhonce@redhat.com)
- Update idler code for new envars (jhonce@redhat.com)
- Merge branch 'master' into US2109 (jhonce@redhat.com)
- Merge branch 'master' into US2109 (jhonce@redhat.com)
- Merge branch 'master' into US2109 (ramr@redhat.com)
- Merge branch 'master' into US2109 (ramr@redhat.com)
- Merge branch 'master' into US2109 (ramr@redhat.com)
- Merge branch 'master' into US2109 (ramr@redhat.com)
- Migrate state, repo and logs. (ramr@redhat.com)
- Support new location for .state file (jhonce@redhat.com)

* Tue May 22 2012 Adam Miller <admiller@redhat.com> 0.93.3-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- EPEL updated mcollective and broke the build! forcing mcollective 1.1.2
  (admiller@redhat.com)
- Several types of log entries were missing exit records.  Synchronize to the
  yaml serialization entry if we fall off an event. (rmillner@redhat.com)
- The mcollective log profiler needs this log message to find the end of a
  call. (rmillner@redhat.com)
- Changes to connect to mongo on standalone gear. (mpatel@redhat.com)

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.93.2-1
- remove preconfigure (dmcphers@redhat.com)
- reset migration for release 2.0.12 (dmcphers@redhat.com)
- Add ability to run the quota command. (rmillner@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.93.1-1
- bumping spec versions (admiller@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.92.5-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix for 'empty? undefined for <uid>:Fixnum' during app create
  (rpenta@redhat.com)

* Tue May 08 2012 Adam Miller <admiller@redhat.com> 0.92.4-1
- Bug 819739 (dmcphers@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.92.3-1
- Migrate app ctl file. (rmillner@redhat.com)
- adding mcollective call to fetch the application state from the .state file
  on each gear (abhgupta@redhat.com)
- Cleanup. (mpatel@redhat.com)
- TA2025 (bdecoste@gmail.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.92.2-1
- Cleanup. (mpatel@redhat.com)
- Changes to make inline library calls for ss commands. (mpatel@redhat.com)
- Notify when a start or stop times out. (rmillner@redhat.com)
- Raise the timeout to compensate for heavy IO during system start dragging
  start times out. (rmillner@redhat.com)
- Add a 60 second timeout (3x measured cost of a couple of apps) on starting
  any gear in the parallel gear start. (rmillner@redhat.com)
- next generation migration (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix rhc-autoidler (rpenta@redhat.com)
- Forgot to add rhc-profiler-merge-report to the specfile.
  (rmillner@redhat.com)
- Add average call time. (rmillner@redhat.com)
- Filter function breaks unless the filter list is a static class global.
  Allow a list of filters. (rmillner@redhat.com)
- Rewrite filters and finish the filter set. (rmillner@redhat.com)
- Fix mcollective log tracking.  Correct for missing timezone in mcollective
  log entries.  Print report. (rmillner@redhat.com)
- Make options global. (rmillner@redhat.com)
- Fill out matcher class.  Change the mcollective log class so that it slurps
  in the whole file set and produces a unified array of events.  This also
  allows it to parse events that cross a log file. (rmillner@redhat.com)
- profile correlator script. (rmillner@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.92.1-1
- bumping spec versions (admiller@redhat.com)

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 0.91.5-1
- Fix for bug# 815609 (rpenta@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 0.91.4-1
- Switch to Time module and add beginning and ent time parsing.
  (rmillner@redhat.com)
- Add command line options. (rmillner@redhat.com)
- Bug fix - handle cases when migration is run multiple times.
  (ramr@redhat.com)
- Add average call time (rmillner@redhat.com)
- Account for all of the calls in a parallel execution by taking the whole
  execute time and dividing it up among each call.  Its not perfectly accurate,
  but its good enough with the data at hand. (rmillner@redhat.com)
- Migrate old haproxy registries to new format (ramr@redhat.com)
- Corrected test BZ814024 (jhonce@redhat.com)

* Wed Apr 18 2012 Adam Miller <admiller@redhat.com> 0.91.3-1
- Added check to not idle stopped application (jhonce@redhat.com)
- Caught in the middle of a log message. (rmillner@redhat.com)
- Add cartridge name to the profile output (rmillner@redhat.com)
- Cleanup output (rmillner@redhat.com)
- Add the mcollective-log-profile command to specfile (rmillner@redhat.com)
- add a spare blank line to pretty up output. (rmillner@redhat.com)
- Print the call profile most expensive first. (rmillner@redhat.com)
- Add the mcollective call profiler. (rmillner@redhat.com)
- bug 808544 (dmcphers@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Add libevent and libevent-devel to list of packages to install.
  (ramr@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.2-1
- release bump for tag uniqueness (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.5-1
- Bug fix for 809567 to use OPENSHIFT_DB_GEAR_DNS to access mysql from haproxy
  gear. (ramr@redhat.com)

* Wed Apr 04 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.4-1
- temporary disabling of these package checks (mmcgrath@redhat.com)

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.3-1
- fixing accept-node (mmcgrath@redhat.com)

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.2-1
- Changed to use fastest approach so far based on benchmarks.
  (mpatel@redhat.com)

* Sat Mar 31 2012 Dan McPherson <dmcphers@redhat.com> 0.90.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.2-1
- The link is failing in actual stage testing. (rmillner@redhat.com)
- 806473 (dmcphers@redhat.com)
- Needed to explicitly copy the string object since its modified in place later
  (rmillner@redhat.com)
- Fix application symlinks if they refer to the old paths.
  (rmillner@redhat.com)
- Add the rhc-app-gear-xlate script back in (rmillner@redhat.com)
- Start migrate 2.0.7a to fix migration issues after production.
  (rmillner@redhat.com)
- The APP_DIR file needed to be retained.  Re-exposing it.
  (rmillner@redhat.com)
- Putting it back in to maintain a little longer. Revert "The app to gear
  variable migration is no longer needed." (rmillner@redhat.com)
- parallelize mcollective calls for parallel jobs (dmcphers@redhat.com)
- The app to gear variable migration is no longer needed. (rmillner@redhat.com)
- base 2.0.8 migration (dmcphers@redhat.com)
- group mcollective calls (dmcphers@redhat.com)
- 7000 too low, builds break (mmcgrath@redhat.com)
- correcting resource_limits syntax error (mmcgrath@redhat.com)
- merge (mmcgrath@redhat.com)
- Further optimization. (mpatel@redhat.com)
- use resource limits to determine jboss heap size with placeholders for larger
  sizes (dmcphers@redhat.com)
- Adding a default cfs_quota (mmcgrath@redhat.com)
- keep around OPENSHIFT_APP_DNS (dmcphers@redhat.com)
- Updating migration script to not change li/libra paths in user files
  (kraman@gmail.com)

* Sat Mar 17 2012 Dan McPherson <dmcphers@redhat.com> 0.89.1-1
- bump spec numbers (dmcphers@redhat.com)
- USER_APP_NAME -> APP_NAME (dmcphers@redhat.com)
- Add APP_NAME to the list of retained variables. (rmillner@redhat.com)
- missing variable migration (rmillner@redhat.com)
- Had missed the existing jenkins block (rmillner@redhat.com)
- Dont need verbose output from the file edit. (rmillner@redhat.com)
- Update jenkins config.xml and per-job config.xml to reflect new gear sizes.
  (rmillner@redhat.com)
- Uncomment jenkins diy migration. (mpatel@redhat.com)

* Thu Mar 15 2012 Dan McPherson <dmcphers@redhat.com> 0.88.8-1
- This was well on the slippery slope to being a migration script.  Moving the
  migration part to the release ticket. (rmillner@redhat.com)
- single quote style seems to be preferred (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- The legacy APP env files were fine for bash but we have a number of parsers
  which could not handle the new format.  Move legacy variables to the app_ctl
  scripts and have migration set the TRANSLATE_GEAR_VARS variable to include
  pairs of variables to migrate. (rmillner@redhat.com)
- Further optimization to reduce search time. (mpatel@redhat.com)
- Bug 803581 (dmcphers@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.7-1
- Removing rhc-idle-apps. (mpatel@redhat.com)
- Removing unused file from spec. (mpatel@redhat.com)
- Fix for Bugzilla 801985 (mpatel@redhat.com)
- Refactored for .state to be after original tests for idle (jhonce@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Escape the # character (rmillner@redhat.com)
- Copy over old proxies if creating a new proxy cfg (rmillner@redhat.com)
- Rename libra-proxy to stickshift-proxy (rmillner@redhat.com)
- Bug 803267: Fixing incorrect path (rmillner@redhat.com)
- enable support for cfs quotas (mmcgrath@redhat.com)
- Fixing migration script for jenkins and jboss apps Also updated notes
  https://engineering.redhat.com/trac/Libra/ticket/149 (kraman@gmail.com)

* Tue Mar 13 2012 Dan McPherson <dmcphers@redhat.com> 0.88.6-1
- The values of stickshift-node.conf were being overridden after libra-data,
  should be before. (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Reload should actually do that. (rmillner@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (abhgupta@redhat.com)
- fixing path (abhgupta@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Discovered this would always retry 60 times each variable  while testing
  other changes (rmillner@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (abhgupta@redhat.com)
- fixing missing module variable (abhgupta@redhat.com)
- Added a param to specify number of days. (mpatel@redhat.com)
- Raw to diy migration. (mpatel@redhat.com)
- Give libra-data the ability to uncomment these variables
  (rmillner@redhat.com)
- Since libra.rb sources the configuration, PUBLIC_IP and PUBLIC_HOSTNAME are
  no longer optional.  But in order for the dev/build/test environment to work
  we still need a way to override them.  Separate out the usage of
  PUBLIC_IP_OVERRIDE and PUBLIC_HOSTNAME_OVERRIDE from PUBLIC_IP and
  PUBLIC_HOSTNAME so that OVERRIDE is optional and can be used from devenv.
  (rmillner@redhat.com)
- moving li/stickshift/node/lib/stickshift-node/express to li/node/lib
  (abhgupta@redhat.com)
- Fix to chown in migrate script. (mpatel@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- BugzID 802387 (kraman@gmail.com)
- The old variables are designed to track the values of the new ones until they
  are re-used for another purpose.  This behaved poorly if the new ones went
  away entirely. (rmillner@redhat.com)
- Migrate script recreates app-symlinks (for devenv) and handles env vars
  (kraman@gmail.com)
- Change remaining references from /usr/libexec/li to /usr/libexec/stickshift
  (rmillner@redhat.com)
- Bug fixes in migrate script (checkpoint, migrates all except jenkins and
  broker-mongo-ds) (kraman@gmail.com)
- Migration for li/libra => stickshift change (checkpoint, covers all but
  jenkins case, does not cover change to httpd.d/*) (kraman@gmail.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Either rhc-accept-node is running alongside other selinux commands or there's
  multiple instances of rhc-accept-node running simultaneously.  This works
  around the semodule lock conflict that keeps coming up in testing.
  (rmillner@redhat.com)

* Mon Mar 12 2012 Dan McPherson <dmcphers@redhat.com> 0.88.5-1
- remove jenkinsUrl from config.xml (dmcphers@redhat.com)
- Change strategy for old variables.  Leave the old files in place, source the
  new file in case its value changes. (rmillner@redhat.com)
- /var/lib/libra became /var/lib/stickshift in the stickshift merge.
  (rmillner@redhat.com)
- rhc-accept-node: added a check for the system httpd configs to catch configs
  that don't have an associated user account (twiest@redhat.com)
- adding back jenkinsUrl for now (dmcphers@redhat.com)
- semicolon is a valid character with connector-hook output now.
  (rchopra@redhat.com)

* Sat Mar 10 2012 Dan McPherson <dmcphers@redhat.com> 0.88.4-1
- rhc-admin-chk (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Local migration includes variable name transition (rmillner@redhat.com)
- Add the gear translator script (rmillner@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Was in the wrong directory (rmillner@redhat.com)
- Fix issues stickshift merge missed. (ramr@redhat.com)
- Needed to be in the proper directory (rmillner@redhat.com)
- Do the variable name transitions in a .env directory supplied on the command
  line (rmillner@redhat.com)

* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.88.3-1
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Fixes to get connections executing. (ramr@redhat.com)
- Add set db connection info connector. (ramr@redhat.com)

* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.88.2-1
- Fix to select correct trap-user script (kraman@gmail.com)
- Build fixes (kraman@gmail.com)
- force jenkins to https (dmcphers@redhat.com)
- Batch variable name chage (rmillner@redhat.com)
- Fixing missing connection hooks in abstract cartridge (kraman@gmail.com)
- Fix factor code to read node config properly Fix rhc-admin-add-template to
  store yaml for descriptor (kraman@gmail.com)
- Put our version of node.conf back whenever the stickshift-node package is
  installed. (rmillner@redhat.com)
- Changing permission to allow stickshift confi files to be user readable
  (kraman@gmail.com)
- Moved abstract carts from rhc-node (kraman@gmail.com)
- Updates for getting devenv running (kraman@gmail.com)
- NodeJS update li/libra => stickshift (kraman@gmail.com)
- Renaming Cloud-SDK -> StickShift (kraman@gmail.com)
- switching to new mirror1 repo (dmcphers@redhat.com)
- Re-enable both flavors of mysql. (ramr@redhat.com)
- Add publication of git url and http proxy info to nodejs. Rename the
  connection hook name in the abstract cartridge. (ramr@redhat.com)
- Return success if file doesn't exist. (ramr@redhat.com)
- Need to fix trap user to handle .uservars directory as well and ignore the
  USER_VARS script. (ramr@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Add support functions for scalable apps and connectors. (ramr@redhat.com)
- Do not change state to stopped if already idle (jhonce@redhat.com)
- Select the new gear sizes (rmillner@redhat.com)
- Updated system resource limits configuration for std->small and large->med
  (rmillner@redhat.com)
- checkpoint 2 - parallel execution over mcollective - not integrated yet
  (rchopra@redhat.com)
- Corrected test for existence of state file (jhonce@redhat.com)
- Updated copyright headers to match concrete cartridges (jhonce@redhat.com)
- Merge branch 'force-stop' (jhonce@redhat.com)
- set application state to stopped on force-stop (jhonce@redhat.com)
- add base 2.0.7 migration (dmcphers@redhat.com)
- Incorrect offset for ip address range. (rmillner@redhat.com)
- bug 798866 (bdecoste@gmail.com)
- Renamed OPENSHIFT_APP_STATE to OPENSHIFT_RUNTIME_DIR (jhonce@redhat.com)

* Fri Mar 02 2012 Dan McPherson <dmcphers@redhat.com> 0.88.1-1
- bump spec numbers (dmcphers@redhat.com)
- Fix for bug# 799515 (rpenta@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Bug fix - don't start embedded cartridges for stopped applications.
  (ramr@redhat.com)
- allow tail to work for links (dmcphers@redhat.com)
- handle state properly from ruby (dmcphers@redhat.com)
- fix migrate for .state (dmcphers@redhat.com)
- Fixed idler stats script. (mpatel@redhat.com)
- create .state file during migration (jhonce@redhat.com)
- used wrong name for idled (dmcphers@redhat.com)

* Thu Mar 01 2012 Dan McPherson <dmcphers@redhat.com> 0.87.9-1
- Bug 798867 (dmcphers@redhat.com)
- handle idled on restart as well (dmcphers@redhat.com)
- Bug 798888 (dmcphers@redhat.com)

* Wed Feb 29 2012 Dan McPherson <dmcphers@redhat.com> 0.87.8-1
- Support new server.log time format BZ795331 (jhonce@redhat.com)
- Removed extra line send_attr line (jhonce@redhat.com)
- Bug fix to properly invoke the command. (ramr@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Cleanup to put the cdk-connector-execute workaround in the utility extensions
  for express. (ramr@redhat.com)
- Bugzilla 798587 (mpatel@redhat.com)
- Fixed the libra_server in url. (mpatel@redhat.com)
- Moved recording the state further up the stack (jhonce@redhat.com)
- Moved marking building/deploying state from build/deploy.sh to
  user_build/user_deploy.sh (jhonce@redhat.com)
- Minor typos in shell notice (mhicks@redhat.com)
- Bug 798529 (dmcphers@redhat.com)

* Tue Feb 28 2012 Dan McPherson <dmcphers@redhat.com> 0.87.7-1
- Allow applications to restart after migration (jhonce@redhat.com)

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
- replace OPENSHIFT_GEAR_DIR in httpd start (bdecoste@gmail.com)

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
