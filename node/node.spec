%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Multi-tenant cloud management system node tools
Name:          rhc-node
Version:       0.80.15
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-node-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: ruby
Requires:      rhc-common
Requires:      rhc-selinux
Requires:      git
Requires:      libcgroup
Requires:      mcollective
Requires:      perl
Requires:      ruby
Requires:      rubygem-open4
Requires:      rubygem-parseconfig
Requires:      quota
Requires:      lsof
Requires:      wget
Requires(post):   /usr/sbin/semodule
Requires(post):   /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule
Requires(postun): /usr/sbin/semanage

BuildArch: noarch

%description
Turns current host into a OpenShift managed node

%prep
%setup -q

%build
for f in **/*.rb
do
  ruby -c $f
done

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libexecdir}
mkdir -p %{buildroot}%{_initddir}
mkdir -p %{buildroot}%{ruby_sitelibdir}
mkdir -p %{buildroot}/var/lib/libra
mkdir -p %{buildroot}%{_libexecdir}/li
mkdir -p %{buildroot}%{_sysconfdir}/httpd/conf.d/libra
mkdir -p %{buildroot}/usr/share/selinux/packages
mkdir -p %{buildroot}%{_sysconfdir}/cron.daily/
mkdir -p %{buildroot}%{_sysconfdir}/libra/skel

cp -r cartridges %{buildroot}%{_libexecdir}/li
cp -r conf/httpd %{buildroot}%{_sysconfdir}
cp -r conf/libra %{buildroot}%{_sysconfdir}
cp -r facter %{buildroot}%{ruby_sitelibdir}/facter
cp -r mcollective %{buildroot}%{_libexecdir}
cp scripts/bin/* %{buildroot}%{_bindir}
cp scripts/init/* %{buildroot}%{_initddir}
cp scripts/libra_tmpwatch.sh %{buildroot}%{_sysconfdir}/cron.daily/libra_tmpwatch.sh

%clean
rm -rf $RPM_BUILD_ROOT

%post
# mount all desired cgroups under a single root
perl -p -i -e 's:/cgroup/[^\s]+;:/cgroup/all;:; /blkio|cpuset|devices/ && ($_ = "#$_")' /etc/cgconfig.conf
/sbin/restorecon /etc/cgconfig.conf || :
# only restart if it's on
chkconfig cgconfig && /sbin/service cgconfig restart >/dev/null 2>&1 || :
/sbin/chkconfig --add libra || :
/sbin/chkconfig --add libra-data || :
/sbin/chkconfig --add libra-cgroups || :
/sbin/chkconfig --add libra-tc || :
#/sbin/service mcollective restart > /dev/null 2>&1 || :
/sbin/restorecon /etc/init.d/libra || :
/sbin/restorecon /var/lib/libra || :
/usr/bin/rhc-restorecon || :
# only enable if cgconfig is
chkconfig cgconfig && /sbin/service libra-cgroups start > /dev/null 2>&1 || :
# only enable if cgconfig is
chkconfig cgconfig && /sbin/service libra-tc start > /dev/null 2>&1 || :
/sbin/service libra-data start > /dev/null 2>&1 || :
echo "/usr/bin/trap-user" >> /etc/shells
/sbin/restorecon /etc/init.d/libra || :
/sbin/restorecon /etc/init.d/mcollective || :
[ $(/usr/sbin/semanage node -l | /bin/grep -c 255.255.255.128) -lt 1000 ] && /usr/bin/rhc-ip-prep.sh || :

# Ensure the default users have a more restricted shell then normal.
#semanage login -m -s guest_u __default__ || :

%preun
if [ "$1" -eq "0" ]; then
    /sbin/service libra-tc stop > /dev/null 2>&1 || :
    /sbin/service libra-cgroups stop > /dev/null 2>&1 || :
    /sbin/chkconfig --del libra-tc || :
    /sbin/chkconfig --del libra-cgroups || :
    /sbin/chkconfig --del libra-data || :
    /sbin/chkconfig --del libra || :
    /usr/sbin/semodule -r libra
    sed -i -e '\:/usr/bin/trap-user:d' /etc/shells
fi

%postun
if [ "$1" -eq 0 ]; then
    /sbin/service mcollective restart > /dev/null 2>&1 || :
fi
#/usr/sbin/semodule -r libra

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/libra.ddl
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/libra.rb
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/migrate-util.rb
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/migrate-2.1.7.rb
%attr(0750,-,-) %{_libexecdir}/mcollective/update_yaml.rb
%attr(0640,-,-) %{ruby_sitelibdir}/facter/libra.rb
%attr(0750,-,-) %{_initddir}/libra
%attr(0750,-,-) %{_initddir}/libra-data
%attr(0750,-,-) %{_initddir}/libra-cgroups
%attr(0750,-,-) %{_initddir}/libra-tc
%attr(0755,-,-) %{_bindir}/trap-user
%attr(0750,-,-) %{_bindir}/rhc-ip-prep.sh
%attr(0750,-,-) %{_bindir}/rhc-restorecon
%attr(0750,-,-) %{_bindir}/rhc-init-quota
%attr(0750,-,-) %{_bindir}/ec2-prep.sh
%attr(0750,-,-) %{_bindir}/remount-secure.sh
%attr(0755,-,-) %{_bindir}/rhc-cgroup-read
%dir %attr(0751,root,root) %{_localstatedir}/lib/libra
%dir %attr(0755,root,root) %{_libexecdir}/li/cartridges/li-controller/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/li-controller/info/hooks/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/li-controller/info/build/
%attr(0640,-,-) %{_libexecdir}/li/cartridges/li-controller/info/data/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/li-controller/info/bin/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/li-controller/info/lib/
%{_libexecdir}/li/cartridges/li-controller/README
%{_libexecdir}/li/cartridges/li-controller/info
%dir %attr(0755,root,root) %{_libexecdir}/li/cartridges/abstract-httpd/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract-httpd/info/hooks/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract-httpd/info/bin/
%{_libexecdir}/li/cartridges/abstract-httpd/info
%dir %attr(0755,root,root) %{_libexecdir}/li/cartridges/abstract/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract/info/hooks/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract/info/bin/
%{_libexecdir}/li/cartridges/abstract/info
%attr(0750,-,-) %{_bindir}/rhc-accept-node
%attr(0750,-,-) %{_bindir}/rhc-node-account
%attr(0750,-,-) %{_bindir}/rhc-node-application
%attr(0755,-,-) %{_bindir}/rhcsh
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/libra/node.conf
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/libra/resource_limits.con*
%attr(0750,-,-) %config(noreplace) %{_sysconfdir}/cron.daily/libra_tmpwatch.sh
%attr(0750,root,root) %config(noreplace) %{_sysconfdir}/httpd/conf.d/000000_default.conf
%attr(0640,root,root) %{_sysconfdir}/httpd/conf.d/libra

%changelog
* Tue Oct 18 2011 Dan McPherson <dmcphers@redhat.com> 0.80.15-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- using whoami to get logname (mmcgrath@redhat.com)

* Tue Oct 18 2011 Dan McPherson <dmcphers@redhat.com> 0.80.14-1
- 

* Tue Oct 18 2011 Dan McPherson <dmcphers@redhat.com> 0.80.13-1
- add migration for existing mysql apps (dmcphers@redhat.com)

* Tue Oct 18 2011 Matt Hicks <mhicks@redhat.com> 0.80.12-1
- Bug 745749 (dmcphers@redhat.com)
- add include guard to libs (dmcphers@redhat.com)
- rewrite migration to be multi threaded per node (dmcphers@redhat.com)

* Mon Oct 17 2011 Dan McPherson <dmcphers@redhat.com> 0.80.11-1
- undo redirection (dmcphers@redhat.com)

* Mon Oct 17 2011 Dan McPherson <dmcphers@redhat.com> 0.80.10-1
- less output on configure (dmcphers@redhat.com)

* Mon Oct 17 2011 Dan McPherson <dmcphers@redhat.com> 0.80.9-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Ensuring all services are started when issuing a 'start'
  (mmcgrath@redhat.com)
- add abstract (more generic than httpd)  cart and use from existing carts
  (dmcphers@redhat.com)
- making bash type (mmcgrath@redhat.com)
- increasing nproc limit (mmcgrath@redhat.com)
- Added support for force-stop (mmcgrath@redhat.com)
- Allow force-stop (mmcgrath@redhat.com)

* Mon Oct 17 2011 Dan McPherson <dmcphers@redhat.com> 0.80.8-1
- Bug 746583 (dmcphers@redhat.com)

* Sun Oct 16 2011 Dan McPherson <dmcphers@redhat.com> 0.80.7-1
- abstract out remainder of deconfigure (dmcphers@redhat.com)

* Sat Oct 15 2011 Dan McPherson <dmcphers@redhat.com> 0.80.6-1
- move jenkins specific method back to jenkins (dmcphers@redhat.com)

* Sat Oct 15 2011 Dan McPherson <dmcphers@redhat.com> 0.80.5-1
- abstract out common vars in remaining hooks (dmcphers@redhat.com)
- more abstracting (dmcphers@redhat.com)
- switch error to warning on git removal fail more abstracting
  (dmcphers@redhat.com)
- more abstracting (dmcphers@redhat.com)
- more abstracting of common code (dmcphers@redhat.com)
- move sources to the top and abstract out error method (dmcphers@redhat.com)
- missed a mcs_level in start (dmcphers@redhat.com)
- move simple functions to source files (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.4-1
- fix param order (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.3-1
- abstract destroy git repo and rm httpd proxy (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.2-1
- Bug 746182 (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.1-1
- fix spec number (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.70.3-1
- handle space in desc passing (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.70.2-1
- abstract create_repo (dmcphers@redhat.com)
- fix typo (dmcphers@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.70.1-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 745749 (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.18-1
- abstract out find_open_ip (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.17-1
- abstract rm_symlink (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.16-1
- abstract out common logic (dmcphers@redhat.com)
- Bug 745373 and remove sessions where not needed (dmcphers@redhat.com)
- Bug 745401 (dmcphers@redhat.com)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.79.15-1
- mv pw to password-file and create jenkins-client-1.4 dir
  (dmcphers@redhat.com)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.79.14-1
- add authentication to jenkins (dmcphers@redhat.com)
- Disable IPV6 in libra init.d file (tkramer@tkramer.timtech)
- Removed ipv6 disable (tkramer@tkramer.timtech)
- Disable IPV6 (tkramer@tkramer.timtech)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.79.13-1
- fix unused get framework too (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.12-1
- pre_deploy -> pre_build (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.11-1
- post receive cleanup (dmcphers@redhat.com)
- call build instead of post receive (dmcphers@redhat.com)
- common post receive and add pre deploy (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- correctly checking for post_deploy script (mmcgrath@redhat.com)
- Allow post_deploy (mmcgrath@redhat.com)
- Adding post_deploy methods (mmcgrath@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.10-1
- make start/stop blocking (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- fixing deploy (mmcgrath@redhat.com)
- more jenkins job work (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.9-1
- add deploy step and call from jenkins with stop start (dmcphers@redhat.com)
- Adding deploy.sh (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Adding ctl_all command and fixing rhcsh path (mmcgrath@redhat.com)

* Sun Oct 09 2011 Dan McPherson <dmcphers@redhat.com> 0.79.8-1
- change fix to be based on suggestion (dmcphers@redhat.com)
- Bug 744513 (dmcphers@redhat.com)
- Bug 744375 (dmcphers@redhat.com)

* Sat Oct 08 2011 Dan McPherson <dmcphers@redhat.com> 0.79.7-1
- use alternate skeleton for new users (markllama@redhat.com)
- added empty skeleton directory for new users (markllama@redhat.com)
- missed one JENKINS_URL (dmcphers@redhat.com)

* Thu Oct 06 2011 Dan McPherson <dmcphers@redhat.com> 0.79.6-1
- add jenkins build kickoff to all post receives (dmcphers@redhat.com)
- add m2_home, java_home, update path, add migration for each and jenkins job
  jboss template (dmcphers@redhat.com)
- Adding rsync support (mmcgrath@redhat.com)
- fix some deconfigures for httpd proxy (dmcphers@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.79.5-1
- add ipv4 and split out standalone.sh and standalone.conf
  (dmcphers@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.79.4-1
- undo test (dmcphers@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.79.3-1
- trying to figure out whats wrong with the ami (dmcphers@redhat.com)
- fixing whitespace (mmcgrath@redhat.com)
- allow libra-data to run on non-EC2 nodes (markllama@redhat.com)

* Tue Oct 04 2011 Dan McPherson <dmcphers@redhat.com> 0.79.2-1
- cleanup (dmcphers@redhat.com)
- cleanup (dmcphers@redhat.com)
- add deploy httpd proxy and migration (dmcphers@redhat.com)
- beginning of migrate 2.1.6 (dmcphers@redhat.com)
- removing agent forward denial (mmcgrath@redhat.com)
- replace update_yaml.pp with update_yaml.rb (blentz@redhat.com)
- properly secure node_data.conf (mmcgrath@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.79.1-1
- bump spec numbers (dmcphers@redhat.com)
- add condition around removing env var (dmcphers@redhat.com)
- add : to allowed args (dmcphers@redhat.com)
- env var add/remove (dmcphers@redhat.com)

* Wed Sep 28 2011 Dan McPherson <dmcphers@redhat.com> 0.78.15-1
- add preconfigure for jenkins to split out auth key gen (dmcphers@redhat.com)

* Wed Sep 28 2011 Dan McPherson <dmcphers@redhat.com> 0.78.14-1
- Correcting bandwidth error (mmcgrath@redhat.com)

* Mon Sep 26 2011 Dan McPherson <dmcphers@redhat.com> 0.78.13-1
- let ssh key alter work with multiple keys (dmcphers@redhat.com)

* Fri Sep 23 2011 Dan McPherson <dmcphers@redhat.com> 0.78.12-1
- up upload limit to 10M (dmcphers@redhat.com)
- fixed typo in openshift_mcs_level (markllama@redhat.com)

* Thu Sep 22 2011 Dan McPherson <dmcphers@redhat.com> 0.78.11-1
- add migration of changing path order (dmcphers@redhat.com)

* Tue Sep 20 2011 Dan McPherson <dmcphers@redhat.com> 0.78.10-1
- added sensitivity (s0:) to the openshift_mcs_level function return value
  (markllama@redhat.com)
- call add and remove ssh keys from jenkins configure and deconfigure
  (dmcphers@redhat.com)

* Mon Sep 19 2011 Dan McPherson <dmcphers@redhat.com> 0.78.9-1
- missed a file on a rename (dmcphers@redhat.com)
- rename migration (dmcphers@redhat.com)
- US1056 (dmcphers@redhat.com)

* Thu Sep 15 2011 Dan McPherson <dmcphers@redhat.com> 0.78.8-1
- set execute perms on mcs_level (markllama@redhat.com)
- updated mcs_level generation for app accounts > 522 (markllama@redhat.com)
- broker auth fixes - functional for adding token (dmcphers@redhat.com)

* Wed Sep 14 2011 Dan McPherson <dmcphers@redhat.com> 0.78.7-1
- disable client gem release (temp) beginnings of broker auth adding barista to
  spec (dmcphers@redhat.com)
- unset x-forwarded-for (mmcgrath@redhat.com)
- fixing paths for token and IV file (mmcgrath@redhat.com)
- allowing broker-auth-key (mmcgrath@redhat.com)
- Add broker auth and remove bits (mmcgrath@redhat.com)

* Mon Sep 12 2011 Dan McPherson <dmcphers@redhat.com> 0.78.6-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (twiest@redhat.com)
- rhc-accept-node: fixed check_app_dirs bug where it would look at symlinks
  (twiest@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Add storage (mmcgrath@redhat.com)
- rhc-accept-node: added check for app dirs without users (twiest@redhat.com)
- rhc-accept-node: added check for empty home dirs (twiest@redhat.com)

* Mon Sep 12 2011 Dan McPherson <dmcphers@redhat.com> 0.78.5-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (twiest@redhat.com)
- rhc-accept-node: fixed libra_device function to work in both devenv and PROD
  (twiest@redhat.com)
- rhc-accept-node: refactored failure message into fail function
  (twiest@redhat.com)
- rhc-accept-node: added check for user home directories (twiest@redhat.com)
- rhc-accept-node: fixed bug where quota errors were not being counted
  (twiest@redhat.com)
- rhc-accept-node: changed the default selinux bool list to check for
  httpd_can_network_connect:on since we use that in STG and PROD
  (twiest@redhat.com)
- rhc-accept-node: removed qpidd from default services as per mmcgrath
  (twiest@redhat.com)

* Mon Sep 12 2011 Dan McPherson <dmcphers@redhat.com> 0.78.4-1
- rhc-accept-node: fixed libra_device to work for long device names
  (twiest@redhat.com)

* Fri Sep 09 2011 Matt Hicks <mhicks@redhat.com> 0.78.3-1
- Adding wget to requires (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- since some of these are files and some are links, we'll want to ensure we hit
  both of them (mmcgrath@redhat.com)
- correcting jumbo type (mmcgrath@redhat.com)
- Added node profile (mmcgrath@redhat.com)
- Added node profile (mmcgrath@redhat.com)
- Added arbitrary capacity planning (mmcgrath@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.78.2-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- changed max_apps_multiplier to max_apps (mmcgrath@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.78.1-1
- Adding max apps multiplier (mmcgrath@redhat.com)
- Adding proper settings for new resource limits (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- Altering how the default resource limit is determined (mmcgrath@redhat.com)
- adding new resource limits to spec file (mmcgrath@redhat.com)
- add system ssh key support along with the beginning of multiple ssh key
  support (dmcphers@redhat.com)
- Added new resrouce limit types (mmcgrath@redhat.com)

* Wed Aug 31 2011 Dan McPherson <dmcphers@redhat.com> 0.77.10-1
- bz726646 patch attempt #2 (markllama@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.9-1
- Revert "Revert "reverse patched to removed commit
  d34abaacc98e5b8f5387eff71064c4616a61f24b"" (markllama@gmail.com)
- Revert "reverse patched to removed commit
  d34abaacc98e5b8f5387eff71064c4616a61f24b" (markllama@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.8-1
- reverse patched to removed commit d34abaacc98e5b8f5387eff71064c4616a61f24b
  (markllama@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.7-1
- bz736646 - allow pty for ssh commands (markllama@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.6-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- increase proxy timeout to 30 (mmcgrath@redhat.com)

* Fri Aug 26 2011 Dan McPherson <dmcphers@redhat.com> 0.77.5-1
- Bug 733227 (dmcphers@redhat.com)

* Thu Aug 25 2011 Dan McPherson <dmcphers@redhat.com> 0.77.4-1
- Adding mkdir (mmcgrath@redhat.com)
- add cname migration added (dmcphers@redhat.com)
- add CNAME support (turned off) (dmcphers@redhat.com)
- Adding support for jenkins slaves (mmcgrath@redhat.com)

* Wed Aug 24 2011 Dan McPherson <dmcphers@redhat.com> 0.77.3-1
- try adding restorecon of aquota.user (dmcphers@redhat.com)

* Wed Aug 24 2011 Dan McPherson <dmcphers@redhat.com> 0.77.2-1
- add to client tools the ability to specify your rsa key file as well as
  default back to id_rsa as a last resort (dmcphers@redhat.com)
- chgrping env (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- do not allow users to alter their own env vars (mmcgrath@redhat.com)
- convert strings to tuples in 'in' comparisons so whole string comparisons get
  done instead of substring (mmcgrath@redhat.com)

* Fri Aug 19 2011 Matt Hicks <mhicks@redhat.com> 0.77.1-1
- fix wsgi apps (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- splitting app_ctl.sh out (dmcphers@redhat.com)

* Thu Aug 18 2011 Dan McPherson <dmcphers@redhat.com> 0.76.17-1
- fix perms on .env (dmcphers@redhat.com)

* Thu Aug 18 2011 Dan McPherson <dmcphers@redhat.com> 0.76.16-1
- fix repo dir for rack on migration (dmcphers@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.15-1
- re-adding (mmcgrath@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.14-1
- moving cgroup-read to correct bin (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Fixing for real this time (mmcgrath@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.13-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- adding cgroup_read (mmcgrath@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.12-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Added cgroup_read (mmcgrath@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.11-1
- 731254 (dmcphers@redhat.com)
- fixing kill calls (mmcgrath@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.10-1
- add app type and db type and migration restart (dmcphers@redhat.com)

* Tue Aug 16 2011 Dan McPherson <dmcphers@redhat.com> 0.76.9-1
- cleanup (dmcphers@redhat.com)

* Tue Aug 16 2011 Dan McPherson <dmcphers@redhat.com> 0.76.8-1
- cleanup how we call snapshot (dmcphers@redhat.com)
- redo the start/stop changes (dmcphers@redhat.com)
- migration fix for post/pre receive (dmcphers@redhat.com)
- split out post and pre receive from the apps (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- prefixing backup and restore with UUID (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- correcting double quote (mmcgrath@redhat.com)

* Tue Aug 16 2011 Matt Hicks <mhicks@redhat.com> 0.76.7-1
- JBoss cgroup and container tuning (mhicks@redhat.com)
- splitting out stop/start, changing snapshot to use stop start and bug 730890
  (dmcphers@redhat.com)
- Added cleanup (mmcgrath@redhat.com)
- allowing user to alter username and password (mmcgrath@redhat.com)
- dirs should end with / (mmcgrath@redhat.com)
- Appending / to dir names (mmcgrath@redhat.com)
- ensuring /tmp ends with a / (mmcgrath@redhat.com)

* Mon Aug 15 2011 Dan McPherson <dmcphers@redhat.com> 0.76.6-1
- adding migration for snapshot/restore (dmcphers@redhat.com)
- snapshot and restore using path (dmcphers@redhat.com)

* Mon Aug 15 2011 Matt Hicks <mhicks@redhat.com> 0.76.5-1
- rename li-controller-0.1 to li-controller (dmcphers@redhat.com)

* Sun Aug 14 2011 Dan McPherson <dmcphers@redhat.com> 0.76.4-1
- adding rhcsh (mmcgrath@redhat.com)
- Added new scripted snapshot (mmcgrath@redhat.com)
- Added rhcsh, as well as _RESTORE functionality (mmcgrath@redhat.com)
- rhcshell bits (mmcgrath@redhat.com)
- restore error handling (dmcphers@redhat.com)
- functional restore (dmcphers@redhat.com)

* Tue Aug 09 2011 Dan McPherson <dmcphers@redhat.com> 0.76.3-1
- get restore to a basic functional level (dmcphers@redhat.com)

* Mon Aug 08 2011 Dan McPherson <dmcphers@redhat.com> 0.76.2-1
- restore work in progress (dmcphers@redhat.com)

* Fri Aug 05 2011 Dan McPherson <dmcphers@redhat.com> 0.76.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Aug 03 2011 Dan McPherson <dmcphers@redhat.com> 0.75.3-1
- increase nproc to 100 (dmcphers@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.75.2-1
- add passenger tmp dir migration (dmcphers@redhat.com)
- migration work (dmcphers@redhat.com)
- add base migration for 2.1.2 (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.1-1
- Export vars (mmcgrath@redhat.com)
- fixing .env ownership (mmcgrath@redhat.com)
- renaming USERNAME to APP_UUID to avoid confusion (mmcgrath@redhat.com)
- Adding environment infrastructure (mmcgrath@redhat.com)
- removing email address from persistent data (mmcgrath@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- add server identity and namespace auto migrate (dmcphers@redhat.com)

* Mon Jul 18 2011 Dan McPherson <dmcphers@redhat.com> 0.74.9-1
- cleanup (dmcphers@redhat.com)

* Mon Jul 18 2011 Dan McPherson <dmcphers@redhat.com> 0.74.8-1
- remove libra specific daemon (mmcgrath@redhat.com)
- 722836 (dmcphers@redhat.com)

* Fri Jul 15 2011 Dan McPherson <dmcphers@redhat.com> 0.74.7-1
- 

* Fri Jul 15 2011 Dan McPherson <dmcphers@redhat.com> 0.74.6-1
- bug 721296 (dmcphers@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.5-1
- mkdir before copy (mmcgrath@redhat.com)
- Adding tmpwatch (mmcgrath@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.4-1
- Changing shell for this command (mmcgrath@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.3-1
- Adding pam_namespace and polyinst /tmp (mmcgrath@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.74.2-1
- Automatic commit of package [rhc-node] release [0.74.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- add options to tail-files (dmcphers@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.13-1].
  (dmcphers@redhat.com)
- Be more forceful about cleanup on removal (mmcgrath@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.12-1].
  (dmcphers@redhat.com)
- remove syntax error from libra-data (dmcphers@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.11-1].
  (dmcphers@redhat.com)
- Adding lsof as a req for node (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.10-1].
  (edirsh@redhat.com)
- Don't include 'embedded' as a cart, ever. (jimjag@redhat.com)
- Adding polyinstantiated tmp dir for pam_namespace (mmcgrath@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.9-1].
  (edirsh@redhat.com)
- simplifying start script - checking for embedded cartridges
  (mmcgrath@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.8-1].
  (dmcphers@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.7-1].
  (dmcphers@redhat.com)
- fixup embedded cart remove (dmcphers@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.6-1].
  (dmcphers@redhat.com)
- perf improvements for how/when we look up the valid cart types on the server
  (dmcphers@redhat.com)
- Merge remote-tracking branch 'origin/master' (markllama@redhat.com)
- switched deconfigure back to symlink to maintain identity with configure
  (markllama@redhat.com)
- updated (de)configure to remove tc elements (markllama@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- fixing embedded call and adding debug (mmcgrath@redhat.com)
- ensure any apps still running from the user are actually dead / gone
  (mmcgrath@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.5-1].
  (dmcphers@redhat.com)
- add nurture migration for existing apps (dmcphers@redhat.com)
- undo passing rhlogin to cart (dmcphers@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)
- fixing merge from Dan (mmcgrath@redhat.com)
- proper error handling for embedded cases (mmcgrath@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.4-1].
  (mhicks@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Added support to call embedded cartridges (mmcgrath@redhat.com)
- Automatic commit of package [rhc-node] release [0.73.3-1].
  (dmcphers@redhat.com)
- Bug 717168 (dmcphers@redhat.com)
- Added embedded list (mmcgrath@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.74.1-1
- bumping spec numbers (dmcphers@redhat.com)
- add options to tail-files (dmcphers@redhat.com)

* Sat Jul 09 2011 Dan McPherson <dmcphers@redhat.com> 0.73.13-1
- Be more forceful about cleanup on removal (mmcgrath@redhat.com)

* Thu Jul 07 2011 Dan McPherson <dmcphers@redhat.com> 0.73.12-1
- remove syntax error from libra-data (dmcphers@redhat.com)

* Tue Jul 05 2011 Dan McPherson <dmcphers@redhat.com> 0.73.11-1
- Adding lsof as a req for node (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Adding polyinstantiated tmp dir for pam_namespace (mmcgrath@redhat.com)

* Tue Jul 05 2011 Emily Dirsh <edirsh@redhat.com> 0.73.10-1
- Don't include 'embedded' as a cart, ever. (jimjag@redhat.com)

* Fri Jul 01 2011 Emily Dirsh <edirsh@redhat.com> 0.73.9-1
- simplifying start script - checking for embedded cartridges
  (mmcgrath@redhat.com)

* Fri Jul 01 2011 Dan McPherson <dmcphers@redhat.com> 0.73.8-1
- 

* Fri Jul 01 2011 Dan McPherson <dmcphers@redhat.com> 0.73.7-1
- fixup embedded cart remove (dmcphers@redhat.com)

* Thu Jun 30 2011 Dan McPherson <dmcphers@redhat.com> 0.73.6-1
- perf improvements for how/when we look up the valid cart types on the server
  (dmcphers@redhat.com)
- Merge remote-tracking branch 'origin/master' (markllama@redhat.com)
- switched deconfigure back to symlink to maintain identity with configure
  (markllama@redhat.com)
- updated (de)configure to remove tc elements (markllama@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- fixing embedded call and adding debug (mmcgrath@redhat.com)
- ensure any apps still running from the user are actually dead / gone
  (mmcgrath@redhat.com)

* Wed Jun 29 2011 Dan McPherson <dmcphers@redhat.com> 0.73.5-1
- add nurture migration for existing apps (dmcphers@redhat.com)
- undo passing rhlogin to cart (dmcphers@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)
- fixing merge from Dan (mmcgrath@redhat.com)
- proper error handling for embedded cases (mmcgrath@redhat.com)

* Tue Jun 28 2011 Matt Hicks <mhicks@redhat.com> 0.73.4-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Added support to call embedded cartridges (mmcgrath@redhat.com)
- Added embedded list (mmcgrath@redhat.com)

* Tue Jun 28 2011 Dan McPherson <dmcphers@redhat.com> 0.73.3-1
- Bug 717168 (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.2-1
- migration fix for app_name == framework (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.1-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (jimjag@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- User.servers not used... clean up factor customer_* and git_cnt_* (US554)
  (jimjag@redhat.com)
- remove git_cnt (jimjag@redhat.com)

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.72.29-1
- 

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.72.28-1
- allow for forcing of IP (mmcgrath@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.72.27-1
- Adding 256M as default quota type (mmcgrath@redhat.com)

* Mon Jun 20 2011 Dan McPherson <dmcphers@redhat.com> 0.72.26-1
- 

* Mon Jun 20 2011 Dan McPherson <dmcphers@redhat.com> 0.72.25-1
- add no-timestamp to archive tar command (dmcphers@redhat.com)

* Fri Jun 17 2011 Dan McPherson <dmcphers@redhat.com> 0.72.24-1
- missed an if (dmcphers@redhat.com)

* Fri Jun 17 2011 Dan McPherson <dmcphers@redhat.com> 0.72.23-1
- add a loop to the recheck ip (dmcphers@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.22-1
- 

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.21-1
- trying a longer sleep (dmcphers@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.20-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (mhicks@redhat.com)
- Adding a sleep if the public ip comes back empty (mhicks@redhat.com)
- fixup path (dmcphers@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.19-1
- missing require (dmcphers@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.18-1
- 

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.17-1
- counting newlines fails with only one line and nl suppressed
  (markllama@redhat.com)

* Wed Jun 15 2011 Dan McPherson <dmcphers@redhat.com> 0.72.16-1
- Update to jboss-as7 7.0.0.Beta6OS, brew buildID=167639
  (scott.stark@jboss.org)
- remove tc entries when deconfiguring an account (markllama@redhat.com)
- add runcon changes for ctl.sh to migration (dmcphers@redhat.com)
- fail selinux checks if even one matches (markllama@redhat.com)
- set Selinux label on Express account root directory (markllama@redhat.com)
- li-controller cleanup (dmcphers@redhat.com)
- move context to libra service and configure Part 3 (dmcphers@redhat.com)
- move context to libra service and configure Part 2 (dmcphers@redhat.com)
- move context to libra service and configure (dmcphers@redhat.com)

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.15-1
- Adding mcs changes (mmcgrath@redhat.com)
- rename to make more sense... (jimjag@redhat.com)
- Force list to be a string... xfer to array when conv (jimjag@redhat.com)
- cart_list factor returns a string now, with cartridges sep by '|'
  (jimjag@redhat.com)
- /usr/lib/ruby/site_ruby/1.8/facter/libra.rb:86:in `+': can't convert String
  into Array (TypeError) (jimjag@redhat.com)
- force array append (jimjag@redhat.com)
- Adjust for permissions (jimjag@redhat.com)
- debug devenv (jimjag@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.14-1
- Be faster (jimjag@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.13-1
- only restart mcollective on _uninstall_ not upgrade (mmcgrath@redhat.com)
- Creating test commits, this is for jenkins (mmcgrath@redhat.com)

* Thu Jun 09 2011 Matt Hicks <mhicks@redhat.com> 0.72.12-1
- Correcting mcollective check to allow periods (mmcgrath@redhat.com)
- Adding shell safe and other checks (mmcgrath@redhat.com)

* Wed Jun 08 2011 Matt Hicks <mhicks@redhat.com> 0.72.11-1
- handle new symlink on rerun (dmcphers@redhat.com)
- migration bug fixes (dmcphers@redhat.com)
- add link from old apptype to new app home (dmcphers@redhat.com)
- add restart to migration (dmcphers@redhat.com)
- move migration to separate file (dmcphers@redhat.com)

* Wed Jun 08 2011 Dan McPherson <dmcphers@redhat.com> 0.72.10-1
- functioning migration (dmcphers@redhat.com)
- minor change (dmcphers@redhat.com)
- migration progress (dmcphers@redhat.com)
- migration updates (dmcphers@redhat.com)
- fixed test bracket typo (markllama@redhat.com)
- fixed shell equality test typo, and made deconfigure require only the account
  name (markllama@redhat.com)
- remove accidentially checked in file (dmcphers@redhat.com)
- fix rhc-snapshot (dmcphers@redhat.com)
- added deconfigure as a symlink to configure (markllama@redhat.com)
- configure reverts if called as deconfigure (markllama@redhat.com)
- removed empty deconfigure script (markllama@redhat.com)
- migration progress (dmcphers@redhat.com)

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.9-1
- 

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.8-1
- moving to sym links for actions (dmcphers@redhat.com)

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.7-1
- OK, so the build failures aren't me. So fold back in (jimjag@redhat.com)
- nother test (jimjag@redhat.com)
- comment out (jimjag@redhat.com)
- fold back in cart factor (jimjag@redhat.com)

* Fri Jun 03 2011 Dan McPherson <dmcphers@redhat.com> 0.72.6-1
- remove apptype dir cleanup (dmcphers@redhat.com)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.5-1
- readjust logic for consistency (jimjag@redhat.com)
- keep carts private/local/static (jimjag@redhat.com)
- Make sure we're really a Dir (jimjag@redhat.com)
- Add in :carts factor we can grab (jimjag@redhat.com)
- customer -> application rename in cartridges (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.4-1
- rpm build issues 3 (dmcphers@redhat.com)
- rpm build issues 2 (dmcphers@redhat.com)
- rpm build issues (dmcphers@redhat.com)
- fix node build (dmcphers@redhat.com)
- move common files to abstract httpd (dmcphers@redhat.com)
- remove apptype dir part 1 (dmcphers@redhat.com)
- add base concept of parent cartridge - work in progress (dmcphers@redhat.com)
- add mod_ssl to site and broker (dmcphers@redhat.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.3-1
- updated package list for node acceptance (markllama@redhat.com)

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-3
- Adding ruby as runtime dependency

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-2
- Readding semanage requirements (mhicks@redhat.com)
- Pulling SELinux RPM out of node (mhicks@redhat.com)

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-3
- Adding rake build dep

* Wed May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Fixing build root dirs

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
