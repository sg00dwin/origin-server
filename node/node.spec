%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Multi-tenant cloud management system node tools
Name:          rhc-node
Version:       0.86.1
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
    /sbin/chkconfig --del libra-tc || :
    /sbin/chkconfig --del libra-cgroups || :
    /sbin/chkconfig --del libra-data || :
    /sbin/chkconfig --del libra || :
    /sbin/chkconfig --del libra-proxy || :
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
%attr(0755,-,-) %{_bindir}/trap-user
%attr(0750,-,-) %{_bindir}/rhc-ip-prep.sh
%attr(0750,-,-) %{_bindir}/rhc-iptables.sh
%attr(0750,-,-) %{_bindir}/rhc-restorecon
%attr(0750,-,-) %{_bindir}/rhc-init-quota
%attr(0750,-,-) %{_bindir}/rhc-list-stale
%attr(0750,-,-) %{_bindir}/rhc-idler
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
#%{_libexecdir}/li/cartridges/abstract/info
%attr(0750,-,-) %{_bindir}/rhc-accept-node
%attr(0755,-,-) %{_bindir}/rhc-list-ports
%attr(0750,-,-) %{_bindir}/rhc-node-account
%attr(0750,-,-) %{_bindir}/rhc-node-application
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
