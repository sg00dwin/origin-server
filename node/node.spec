%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Multi-tenant cloud management system node tools
Name:          rhc-node
Version:       0.78.0
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
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/migrate-0.73.rb
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/migrate-0.74.rb
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/migrate-2.1.2.rb
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/migrate-2.1.3.rb
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/migrate-2.1.4.rb
%attr(0640,-,-) %{_libexecdir}/mcollective/update_yaml.pp
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
%{_libexecdir}/li/cartridges/li-controller/README
%{_libexecdir}/li/cartridges/li-controller/info
%dir %attr(0755,root,root) %{_libexecdir}/li/cartridges/abstract-httpd/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract-httpd/info/hooks/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract-httpd/info/bin/
%{_libexecdir}/li/cartridges/abstract-httpd/info
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
