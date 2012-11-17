%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Multi-tenant cloud management system node tools
Name:          rhc-node
Version: 1.1.7
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
Requires:      ruby193-mcollective-common
Requires:      perl
Requires:      ruby
Requires:      ruby193-rubygem-open4
Requires:      ruby193-rubygem-parseconfig
Requires:      rubygem-openshift-origin-node
Requires:      openshift-origin-node-util
Requires:      ruby193-rubygem-systemu
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
Requires:      GeoIP-devel
Requires:      unixODBC
Requires:      unixODBC-devel
Requires:      Cython
Requires:      Pyrex
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
mkdir -p %{buildroot}%{_sysconfdir}/oddjobd.conf.d/
mkdir -p %{buildroot}%{_sysconfdir}/dbus-1/system.d/
mkdir -p %{buildroot}%{_sysconfdir}/cron.daily/
mkdir -p %{buildroot}%{_sysconfdir}/openshift/skel
mkdir -p %{buildroot}/%{_var}/www/html/
mkdir -p %{buildroot}/%{_sysconfdir}/security/
mkdir -p %{buildroot}%{_var}/lib/openshift
mkdir -p %{buildroot}%{_var}/run/openshift
mkdir -p %{buildroot}%{_var}/lib/openshift/.httpd.d
mkdir -p %{buildroot}/%{_sysconfdir}/httpd/conf.d/
mkdir -p %{buildroot}/lib64/security/
mkdir -p %{buildroot}/sandbox
# ln -s %{_var}/lib/openshift/.httpd.d/ %{buildroot}/%{_sysconfdir}/httpd/conf.d/openshift

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
/sbin/service libra-watchman restart || :
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
%dir %attr(0751,root,root) %{_var}/lib/openshift
%dir %attr(0750,root,root) %{_var}/lib/openshift/.httpd.d
%dir %attr(0700,root,root) %{_var}/run/openshift
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
* Fri Nov 16 2012 Adam Miller <admiller@redhat.com> 1.1.7-1
- Merge pull request #627 from ironcladlou/scl-refactor (dmcphers@redhat.com)
- Only use scl if it's available (ironcladlou@gmail.com)

* Thu Nov 15 2012 Adam Miller <admiller@redhat.com> 1.1.6-1
- more ruby 1.9 changes (dmcphers@redhat.com)

* Wed Nov 14 2012 Adam Miller <admiller@redhat.com> 1.1.5-1
- Merge pull request #610 from danmcp/ruby19 (openshift+bot@redhat.com)
- Merge pull request #611 from ramr/master (openshift+bot@redhat.com)
- Merge pull request #603 from rmillner/inhibitidler (dmcphers@redhat.com)
- sclizing gems (dmcphers@redhat.com)
- Merge pull request #596 from jwhonce/master (openshift+bot@redhat.com)
- Fix for bugz 874454 - can't install bzr. Add missing dependencies.
  (ramr@redhat.com)
- Finish moving stale disable to Origin. (rmillner@redhat.com)
- Fix for Bug 873543 (jhonce@redhat.com)

* Tue Nov 13 2012 Adam Miller <admiller@redhat.com> 1.1.4-1
- Merge pull request #585 from brenton/BZ874587 (openshift+bot@redhat.com)
- Merge pull request #598 from rmillner/BZ875910 (openshift+bot@redhat.com)
- add acceptable errors category (dmcphers@redhat.com)
- better strings (dmcphers@redhat.com)
- Remove duplicate script. (rmillner@redhat.com)
- Add additional timings for migrations (dmcphers@redhat.com)
- Bug 874587 - CLOUD_NAME in /etc/openshift/node.conf does not work
  (bleanhar@redhat.com)

* Mon Nov 12 2012 Adam Miller <admiller@redhat.com> 1.1.3-1
- Old copy of this file was not deleted when it moved to origin.
  (rmillner@redhat.com)
- Fix bugz 874826 - pyodbc install fails - needs odbc libraries + headers.
  (ramr@redhat.com)

* Thu Nov 08 2012 Adam Miller <admiller@redhat.com> 1.1.2-1
- Increase the table sizes to cover 15000 nodes in dev and prod.
  (rmillner@redhat.com)
- Add GeoIP-devel to node to allow for geoip modules to be compiled.
  (ramr@redhat.com)
- update migration to 2.0.20 (dmcphers@redhat.com)
- Fix mongodb permissions issue w/ the migrator - bugz 872494 - affect the
  symlink not the target. (ramr@redhat.com)

* Thu Nov 01 2012 Adam Miller <admiller@redhat.com> 1.1.1-1
- bump_minor_versions for sprint 20 (admiller@redhat.com)
- Remove redundant comment. (rmillner@redhat.com)
- Only set MCS labels on cart dirs, git, app-root, etc... (rmillner@redhat.com)
