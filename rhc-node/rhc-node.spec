%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Multi-tenant cloud management system node tools
Name:          rhc-node
Version: 1.0.2
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-node-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: ruby
Requires:      rhc-common
Requires:      rhc-selinux >= 0.84.7-1
Requires:      git
Requires:      libcgroup
Requires:      mcollective
Requires:      perl
Requires:      ruby
Requires:      rubygem-open4
Requires:      rubygem-parseconfig
Requires:      rubygem-openshift-origin-node
Requires:      openshift-origin-node-util
Requires:      rubygem-systemu
Requires:      openshift-origin-cartridge-abstract
Requires:      mcollective-qpid-plugin
Requires:      openshift-origin-msg-node-mcollective
Requires:      openshift-origin-port-proxy
Requires:      quota
Requires:      lsof
Requires:      wget
Requires:      nano
Requires:      emacs-nox
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
Requires:      mod_vhost_choke
Requires(post):   /usr/sbin/semodule
Requires(post):   /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule
Requires(postun): /usr/sbin/semanage


%description
Turns current host into a OpenShift managed node


%prep
%setup -q

%build


%install
rm -rf $RPM_BUILD_ROOT

mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libexecdir}
mkdir -p %{buildroot}%{_initddir}
mkdir -p %{buildroot}%{ruby_sitelibdir}
mkdir -p %{buildroot}%{_libexecdir}/openshift
mkdir -p %{buildroot}/usr/share/selinux/packages
mkdir -p %{buildroot}%{_sysconfdir}/cron.daily/
mkdir -p %{buildroot}%{_sysconfdir}/cron.daily/
mkdir -p %{buildroot}%{_sysconfdir}/openshift/skel
mkdir -p %{buildroot}/%{_localstatedir}/www/html/
mkdir -p %{buildroot}/%{_sysconfdir}/security/
mkdir -p %{buildroot}%{_localstatedir}/lib/openshift
mkdir -p %{buildroot}%{_localstatedir}/run/openshift
mkdir -p %{buildroot}%{_localstatedir}/lib/openshift/.httpd.d
mkdir -p %{buildroot}/%{_sysconfdir}/httpd/conf.d/
mkdir -p %{buildroot}/lib64/security/
mkdir -p %{buildroot}/sandbox
# ln -s %{_localstatedir}/lib/openshift/.httpd.d/ %{buildroot}/%{_sysconfdir}/httpd/conf.d/openshift

cp -r lib %{buildroot}%{_libexecdir}/openshift
cp -r conf/httpd %{buildroot}%{_sysconfdir}
cp -r conf/openshift %{buildroot}%{_sysconfdir}
cp -r mcollective %{buildroot}%{_libexecdir}
cp scripts/bin/* %{buildroot}%{_bindir}
cp scripts/init/* %{buildroot}%{_initddir}
cp scripts/openshift_tmpwatch.sh %{buildroot}%{_sysconfdir}/cron.daily/openshift_tmpwatch.sh

%clean
rm -rf $RPM_BUILD_ROOT

%post
echo "/usr/bin/oo-trap-user" >> /etc/shells

/sbin/chkconfig --add openshift-gears || :
/sbin/chkconfig --add libra-data || :
/sbin/chkconfig --add libra-tc || :
/sbin/chkconfig --add libra-watchman || :
/sbin/chkconfig --add openshift-cgroups || :

#/sbin/service mcollective restart > /dev/null 2>&1 || :
/sbin/restorecon /etc/init.d/libra || :
/sbin/restorecon /var/run/openshift || :
/sbin/restorecon -r /sandbox
/sbin/restorecon /etc/init.d/mcollective || :


# Only bounce cgroups if not already initialized
# CAVEAT: if the policy is changed, must run these by hand (release ticket)
if [ ! -e /cgroup/all/openshift/cgroup.event_control ]
then
    # mount all desired cgroups under a single root
    perl -p -i -e 's:/cgroup/[^\s]+;:/cgroup/all;:; /blkio|cpuset|devices/ && ($_ = "#$_")' /etc/cgconfig.conf
    /sbin/restorecon /etc/cgconfig.conf || :
    # only restart if it's on
    /sbin/chkconfig cgconfig && /sbin/service cgconfig restart >/dev/null 2>&1 || :
    # only enable if cgconfig is
    chkconfig cgconfig && /sbin/service openshift-cgroups start > /dev/null 2>&1 || :
fi

# Only bounce tc if its not already initialized
# CAVEAT: if the policy is changed, must run these by hand (release ticket)
if ! ( tc qdisc show | grep -q 'qdisc htb 1: dev' )
then
    # only enable if cgconfig is
    chkconfig cgconfig && /sbin/service libra-tc start > /dev/null 2>&1 || :
fi

/sbin/chkconfig oddjobd on
/sbin/service messagebus restart
/sbin/service oddjobd restart
# /usr/bin/rhc-restorecon || :    # Takes too long and shouldn't be needded
/sbin/service libra-data start > /dev/null 2>&1 || :
[ $(/usr/sbin/semanage node -l | /bin/grep -c 255.255.255.128) -lt 1000 ] && /usr/bin/rhc-ip-prep.sh || :

# Ensure the default users have a more restricted shell then normal.
#semanage login -m -s guest_u __default__ || :

if [[ -d "/etc/httpd/conf.d/openshift.bak" && -L "/etc/httpd/conf.d/openshift" ]]
then
    mv /etc/httpd/conf.d/openshift.bak/* /var/lib/openshift/.httpd.d/
    # not forced to prevent data loss
    rmdir /etc/httpd/conf.d/openshift.bak
fi

# To workaround mcollective 2.0 monkey patch to tmpdir
chmod o+w /tmp

%triggerin -- rubygem-openshift-origin-node
/sbin/service libra-data start > /dev/null 2>&1 || :

%preun
if [ "$1" -eq "0" ]; then
    /sbin/service libra-tc stop > /dev/null 2>&1 || :
    /sbin/service openshift-cgroups stop > /dev/null 2>&1 || :
    /sbin/service libra-watchman stop > /dev/null 2>&1 || :
    /sbin/chkconfig --del libra-tc || :
    /sbin/chkconfig --del libra-data || :
    /sbin/chkconfig --del openshift-cgroups || :
    /sbin/chkconfig --del libra-watchman || :
    sed -i -e '\:/usr/bin/oo-trap-user:d' /etc/shells
fi

%postun

if [ "$1" -eq 0 ]; then
    /sbin/service mcollective restart > /dev/null 2>&1 || :
fi
#/usr/sbin/semodule -r libra

%pre

if [[ -d "/etc/httpd/conf.d/openshift" && ! -L "/etc/httpd/conf.d/openshift" ]]
then
    mv /etc/httpd/conf.d/openshift/ /etc/httpd/conf.d/openshift.bak/
fi

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/*
%attr(0750,-,-) %{_initddir}/libra-data
%attr(0750,-,-) %{_initddir}/libra-tc
%attr(0750,-,-) %{_initddir}/libra-watchman
%attr(0750,-,-) %{_bindir}/rhc-ip-prep.sh
%attr(0750,-,-) %{_bindir}/rhc-iptables.sh
%attr(0750,-,-) %{_bindir}/rhc-mcollective-log-profile
%attr(0750,-,-) %{_bindir}/rhc-profiler-merge-report
%attr(0750,-,-) %{_bindir}/rhc-restorecon
%attr(0750,-,-) %{_bindir}/rhc-init-quota
%attr(0750,-,-) %{_bindir}/ec2-prep.sh
%attr(0750,-,-) %{_bindir}/remount-secure.sh
%attr(0755,-,-) %{_bindir}/rhc-vhost-choke
%dir %attr(0751,root,root) %{_localstatedir}/lib/openshift
%dir %attr(0750,root,root) %{_localstatedir}/lib/openshift/.httpd.d
%dir %attr(0700,root,root) %{_localstatedir}/run/openshift
#%dir %attr(0755,root,root) %{_libexecdir}/openshift/cartridges/abstract-httpd/
#%attr(0750,-,-) %{_libexecdir}/openshift/cartridges/abstract-httpd/info/hooks/
#%attr(0755,-,-) %{_libexecdir}/openshift/cartridges/abstract-httpd/info/bin/
##%{_libexecdir}/openshift/cartridges/abstract-httpd/info
#%dir %attr(0755,root,root) %{_libexecdir}/openshift/cartridges/abstract/
#%attr(0750,-,-) %{_libexecdir}/openshift/cartridges/abstract/info/hooks/
#%attr(0755,-,-) %{_libexecdir}/openshift/cartridges/abstract/info/bin/
#%attr(0755,-,-) %{_libexecdir}/openshift/cartridges/abstract/info/lib/
#%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract/info/connection-hooks/
%attr(0755,-,-) %{_libexecdir}/openshift/lib/
#%{_libexecdir}/openshift/cartridges/abstract/info
%attr(0750,-,-) %{_bindir}/rhc-accept-node
%attr(0750,-,-) %{_bindir}/rhc-node-account
%attr(0750,-,-) %{_bindir}/rhc-node-application
%attr(0750,-,-) %{_bindir}/rhc-watchman
%attr(0700,-,-) %{_bindir}/migration-symlink-as-user
%attr(0644,-,-) %config(noreplace) %{_sysconfdir}/openshift/node.conf.libra
%attr(0644,-,-) %config(noreplace) %{_sysconfdir}/openshift/resource_limits.con*
%attr(0750,-,-) %config(noreplace) %{_sysconfdir}/cron.daily/openshift_tmpwatch.sh
%attr(0750,root,root) %config(noreplace) %{_sysconfdir}/httpd/conf.d/000000_default.conf
#%attr(0640,root,root) %{_sysconfdir}/httpd/conf.d/openshift
%dir %attr(0755,root,root) %{_sysconfdir}/openshift/skel
%dir %attr(1777,root,root) /sandbox


%changelog
* Wed Oct 31 2012 Adam Miller <admiller@redhat.com> 1.0.2-1
- move broker/node utils to /usr/sbin/ everywhere (admiller@redhat.com)
- Merge pull request #554 from rmillner/BZ870937 (openshift+bot@redhat.com)
- Merge pull request #552 from pmorie/dev/migrations (openshift+bot@redhat.com)
- Fix zend migration. (rmillner@redhat.com)
- Fix incorrect substitutions in haproxy config files for rename migration
  (pmorie@gmail.com)

* Tue Oct 30 2012 Adam Miller <admiller@redhat.com> 1.0.1-1
- Merge pull request #551 from mrunalp/bugs/mig_env_var_1
  (openshift+bot@redhat.com)
- Merge pull request #548 from danmcp/master (openshift+bot@redhat.com)
- Fix for BZ 869236. (mpatel@redhat.com)
- bumping specs to at least 1.0.0 (dmcphers@redhat.com)
- BZ 870937: Needed a migration for Zend. (rmillner@redhat.com)

* Mon Oct 29 2012 Adam Miller <admiller@redhat.com> 0.99.13-1
- Merge pull request #534 from brenton/rhc-list-ports1
  (openshift+bot@redhat.com)
- better debugging on rhc-accept-devenv failures (dmcphers@redhat.com)
- Fix numerous issues with migrations for scalable apps. (pmorie@gmail.com)
- Bug 835501 - 'rhc-port-foward' returns 'No available ports to forward '
  (bleanhar@redhat.com)

* Fri Oct 26 2012 Adam Miller <admiller@redhat.com> 0.99.12-1
- Add substitutions for httpd config files on haproxy gear for scalable apps
  (pmorie@gmail.com)
- Merge pull request #528 from pmorie/dev/migrations (dmcphers@redhat.com)
- Fixes problems with mongodb and postgresql migrations. (pmorie@gmail.com)
- Merge pull request #525 from pmorie/dev/migrations (dmcphers@redhat.com)
- Fixes for migrations of scalable apps (pmorie@gmail.com)

* Wed Oct 24 2012 Adam Miller <admiller@redhat.com> 0.99.11-1
- Merge pull request #513 from ramr/master (openshift+bot@redhat.com)
- Fixes for cron (pmorie@gmail.com)
- Fixes for sshing to migrated apps, jenkins-1.4, phpmyadmin, and rockmongo
  (pmorie@gmail.com)
- Remove rhcsh from li - use the one from origin-server/node/misc/bin/rhcsh.
  (ramr@redhat.com)
- Remove sourcing abstract/info/lib/util -- brings in "cruft" and fix up rhcsh.
  (ramr@redhat.com)

* Fri Oct 19 2012 Adam Miller <admiller@redhat.com> 0.99.10-1
- Change libra guest to OpenShift guest (dmcphers@redhat.com)
- Merge pull request #501 from pmorie/dev/rename (dmcphers@redhat.com)
- Changes for 2.0.19 migrations (pmorie@gmail.com)

* Thu Oct 18 2012 Adam Miller <admiller@redhat.com> 0.99.9-1
- Port auto-Idler to origin-server (jhonce@redhat.com)
- Update to use origin scripts (jhonce@redhat.com)
- Fixes for scripts moved to origin-server (kraman@gmail.com)
- Polydirs moved to Origin.  The /sandbox directory stays in Hosted for now.
  (rmillner@redhat.com)
- Move SELinux to Origin and use new policy definition. (rmillner@redhat.com)

* Mon Oct 15 2012 Adam Miller <admiller@redhat.com> 0.99.8-1
- BZ 864617: Ignore search engine bot entries in log and allow passing log file
  path as an argument. (mpatel@redhat.com)
- Merge pull request #473 from kwoodson/increase_small_capacity
  (openshift+bot@redhat.com)
- resource_limits: Updated from 90 to 100 (kwoodson@redhat.com)
- Migrate to using OpenShift::Config.new (miciah.masters@gmail.com)
- Merge pull request #458 from mrunalp/bugs/cron-migration-fix
  (openshift+bot@redhat.com)
- Fix to use correction function. (mpatel@redhat.com)

* Mon Oct 08 2012 Adam Miller <admiller@redhat.com> 0.99.7-1
- Carrying over migration to 2.0.19 (dmcphers@redhat.com)
- Fixing renames, paths, configs and cleaning up old packages. Adding
  obsoletes. (kraman@gmail.com)

* Thu Oct 04 2012 Adam Miller <admiller@redhat.com> 0.99.6-1
- Bug 862439 patch for fix (jhonce@redhat.com)
- Merge pull request #442 from mrunalp/dev/typeless (dmcphers@redhat.com)
- BZ853582: Prevent user from logging in while deleting gear
  (jhonce@redhat.com)
- Fix for Bug 862439 (jhonce@redhat.com)
- Typeless gear changes for US 2105 (jhonce@redhat.com)
