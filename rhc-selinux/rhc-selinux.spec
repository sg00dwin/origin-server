Summary:       SELinux policy for OpenShift nodes
Name:          rhc-selinux
Version: 1.0.2
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-selinux-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: selinux-policy >= 3.7.19-173
Requires:      selinux-policy-targeted >= 3.7.19-173
Requires:      policycoreutils-python
Requires(post):   /usr/sbin/semanage
Requires(postun): /usr/sbin/semanage

BuildArch: noarch

%description
Supplies the SELinux policy for the OpenShift nodes

%prep
%setup -q

%build
make -f /usr/share/selinux/devel/Makefile
bzip2 -9 openshift-hosted.pp

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_datadir}/selinux/packages
mkdir -p %{buildroot}%{_datadir}/selinux/devel/include/services

install -m 644 openshift-hosted.pp.bz2 %{buildroot}%{_datadir}/selinux/packages/openshift-hosted.pp.bz2
install -m 644 openshift-hosted.if     %{buildroot}%{_datadir}/selinux/devel/include/services/openshift-hosted.if


%clean
rm -rf %{buildroot}

%post
# Not compatible with the old libra policy and older versions of this
# RPM don't remove it.
/usr/sbin/semodule -r libra >/dev/null 2>&1 || :
/usr/sbin/semodule -d openshift-origin >/dev/null 2>&1 || :
/usr/sbin/semodule -i %{_datadir}/selinux/packages/openshift-hosted.pp.bz2 || :

for fixpath in "/sandbox"
do
    [ -e "$fixpath" ] && /sbin/restorecon -R "$fixpath"
done


%postun
if [ $1 = 0 ]
then
    /usr/sbin/semodule -r openshift-hosted -e openshift-origin || :
fi

%files
%defattr(-,root,root,-)
%attr(0644,-,-) %{_datadir}/selinux/packages/openshift-hosted.pp.bz2
%{_datadir}/selinux/devel/include/services/openshift-hosted.if


%changelog
* Wed Oct 24 2012 Adam Miller <admiller@redhat.com> 1.0.2-1
- Fix minor errors with selinux specfile. (rmillner@redhat.com)
- Restorecon on paths owned by the openshift-hosted policy.
  (rmillner@redhat.com)

* Mon Oct 22 2012 Adam Miller <admiller@redhat.com> 1.0.1-1
- Update version since its a radically different policy. (rmillner@redhat.com)
- BZ868262: Move the removal of openshift-origin to a different step to ensure
  that the install works if its already disabled. (rmillner@redhat.com)

* Thu Oct 18 2012 Adam Miller <admiller@redhat.com> 0.98.3-1
- Needed additional ssh policy to allow ssh into gears. (rmillner@redhat.com)
- Consolidate boolean setting with devenv. (rmillner@redhat.com)
- Policy update (rmillner@redhat.com)
- Move SELinux to Origin and use new policy definition. (rmillner@redhat.com)

* Wed Oct 10 2012 Rob Millner <rmillner@redhat.com> 0.98.5-1
- Official openshift-hosted policy (rmillner@redhat.com)
- Move SELinux to Origin and use new policy definition. (rmillner@redhat.com)

* Wed Oct 10 2012 Rob Millner <rmillner@redhat.com> 0.98.4-1
- The devenv build script requires the package to be listed by name.
  (rmillner@redhat.com)

* Wed Oct 10 2012 Rob Millner <rmillner@redhat.com> 0.98.3-1
- Move SELinux to Origin and use new policy definition. (rmillner@redhat.com)

* Mon Oct 08 2012 Adam Miller <admiller@redhat.com> 0.98.2-1
- Fixing renames, paths, configs and cleaning up old packages. Adding
  obsoletes. (kraman@gmail.com)

* Wed Aug 22 2012 Adam Miller <admiller@redhat.com> 0.98.1-1
- bump_minor_versions for sprint 17 (admiller@redhat.com)

* Fri Aug 17 2012 Adam Miller <admiller@redhat.com> 0.97.5-1
- BZ847906: Add whois to allowed list of ports. (rmillner@redhat.com)

* Tue Aug 14 2012 Adam Miller <admiller@redhat.com> 0.97.4-1
- Stop auditing libra instances for searching or listing directories.  This is
  not really intersting from a SELinux point of view (dwalsh@redhat.com)

* Thu Aug 09 2012 Adam Miller <admiller@redhat.com> 0.97.3-1
- Create sandbox directory with proper selinux policy and manage
  polyinstantiation for it. (rmillner@redhat.com)

* Thu Aug 02 2012 Adam Miller <admiller@redhat.com> 0.97.2-1
- Dontaudit libra domains trying to search other libra domains directories,
  this happens just when users are probing the system (dwalsh@redhat.com)

* Thu Aug 02 2012 Adam Miller <admiller@redhat.com> 0.97.1-1
- bump_minor_versions for sprint 16 (admiller@redhat.com)

* Fri Jul 27 2012 Dan McPherson <dmcphers@redhat.com> 0.96.4-1
- Allow libra instances to create lnk_files in /tmp directory
  (dwalsh@redhat.com)

* Tue Jul 24 2012 Adam Miller <admiller@redhat.com> 0.96.3-1
- Lots of updates to quiet AVC's in audit logs (dwalsh@redhat.com)

* Thu Jul 19 2012 Adam Miller <admiller@redhat.com> 0.96.2-1
- Security open up selinux for mysqld binding to 127.0.0.1 (tkramer@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.96.1-1
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.95.2-1
- new package built with tito

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 0.95.1-1
- bump_minor_versions for sprint 14 (admiller@redhat.com)

* Tue Jun 19 2012 Adam Miller <admiller@redhat.com> 0.94.4-1
- Some apps are checking if there is a ~/.ssh in the homedir
  (dwalsh@redhat.com)

* Mon Jun 18 2012 Adam Miller <admiller@redhat.com> 0.94.3-1
- Allow libra_mail_t to write/append inherited file descriptors so users could
  do bash directrion of files (dwalsh@redhat.com)

* Fri Jun 08 2012 Adam Miller <admiller@redhat.com> 0.94.2-1
- Since bash command completions is flooding the logs with read/execute checks
  on lots of executables, we need to add dontaudit rules. (dwalsh@redhat.com)

* Fri Jun 01 2012 Adam Miller <admiller@redhat.com> 0.94.1-1
- bumping spec versions (admiller@redhat.com)

* Wed May 23 2012 Adam Miller <admiller@redhat.com> 0.93.8-1
- Fix for bugz 824356 - Node.js process not started up. (ramr@redhat.com)

* Tue May 22 2012 Adam Miller <admiller@redhat.com> 0.93.7-1
- libra selinux policy now requires 3.7.19-153 targeted (admiller@redhat.com)

* Tue May 22 2012 Adam Miller <admiller@redhat.com> 0.93.6-1
- Allow libra instances to send signals to mail agents that they may have
  spawned (dwalsh@redhat.com)
- Dontaudit libra domains looking at leaked kernel keyring, httpd wants to get
  the parent gid of libra instances (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Update libra instance to allow it to use all jboss ports  Including jabberd.
  (dwalsh@redhat.com)

* Fri May 18 2012 Adam Miller <admiller@redhat.com> 0.93.5-1
- 

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.93.4-1
- bumped selinux-policy dep to match actual requirement (admiller@redhat.com)

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.93.3-1
- 

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.93.2-1
- SELinux lines to allow use of the quota command. (rmillner@redhat.com)
- Allow libra domains to communicate with jboss_messageing ports
  (dwalsh@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.93.1-1
- bumping spec versions (admiller@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.92.4-1
- Revert "Allow libra domains to communicate with jboss_messageing ports"
  (dmcphers@redhat.com)
- reverted yum update selinux in favor or proper spec file requires
  (admiller@redhat.com)
- Allow libra domains to communicate with jboss_messageing ports
  (dwalsh@redhat.com)

* Tue May 08 2012 Adam Miller <admiller@redhat.com> 0.92.3-1
- Dontaudit leaked file descriptors going to crontab_t command
  (dwalsh@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.92.2-1
- revert previous commit 3f29dfed for now (dmcphers@redhat.com)
- Dontaudit libra domains trying to create netlink_tcpdiag_sockets, executing
  ss command causes this, and we have decided to allow libra instances to
  execute ss (dwalsh@redhat.com)
- Remove libra's ability to look at network state (dwalsh@redhat.com)
- fix signull signal name (dwalsh@redhat.com)
- fix signull signal name (dwalsh@redhat.com)
- temporarily revert 27d63c03 that was failing libra_check build
  (admiller@redhat.com)
- Don't allow libra domains to look at sshd_t kernel keyrings
  (dwalsh@redhat.com)
- libra instances should be able to kill the mailer that they launch
  (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Revert "Allow libra to check the access on any file in libra_var_lib_t, this
  allows us to check access on sock_file" (dwalsh@redhat.com)
- temporarily reverted 39860d58ac3b6fad7462f2f9f88b5bc893854df7 to let
  libra_check build succeed (admiller@redhat.com)
- Allow libra to check the access on any file in libra_var_lib_t, this allows
  us to check access on sock_file (dwalsh@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.92.1-1
- bumping spec versions (admiller@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.91.5-1
- Allow libra domains to ask the kernel about what ipc mechanisms are available
  (dwalsh@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 0.91.4-1
- Added fix to libra selinux as per dwalsh (admiller@redhat.com)

* Wed Apr 18 2012 Adam Miller <admiller@redhat.com> 0.91.3-1
- dontaudit httpd starting as libra_t trying to read the httpd_log_t link file
  (dwalsh@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.2-1
- release bump for tag uniqueness (mmcgrath@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.90.4-1
- Allow libra domains to execstack so they can run wacky java apps/processes
  (dwalsh@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.3-1
- Allow libra domains to use ptmx device (dwalsh@redhat.com)

* Mon Apr 09 2012 Mike McGrath <mmcgrath@redhat.com> 0.90.2-1
- Dontaudit leaked sshd_devpts_t to crontab_t. add chsh and chfn to programs
  that libra instances should not be allowed to execute (dwalsh@redhat.com)

* Sat Mar 31 2012 Dan McPherson <dmcphers@redhat.com> 0.90.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Mar 29 2012 Dan McPherson <dmcphers@redhat.com> 0.89.4-1
- Allow libra instances to kill the ping command, this is required since we are
  now allowing users to run ping, need to allow them to kill it.
  (dwalsh@redhat.com)

* Wed Mar 28 2012 Dan McPherson <dmcphers@redhat.com> 0.89.3-1
- Fixes to make sed warnings go aways.  Allow libra domains to setfscreatecon
  (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Allow libra domains to use badly built libraries (dwalsh@redhat.com)

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.2-1
- /var/lib is a symbolic link and libra domains need to be able to read it
  (dwalsh@redhat.com)
- Libra domains want to execute /etc/auto.net type files (dwalsh@redhat.com)

* Sat Mar 17 2012 Dan McPherson <dmcphers@redhat.com> 0.89.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Mar 14 2012 Dan McPherson <dmcphers@redhat.com> 0.88.3-1
- Allow libra domains to change the user componant of the file label, since vi
  attempts to do this by default (dwalsh@redhat.com)

* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.88.2-1
- Updates for getting devenv running (kraman@gmail.com)
- Allow libra domains to relabelfrom/to all classes rather then just file.
  Added mtr to dontallow list, unless we want to allow traceroute type access
  (dwalsh@redhat.com)
- dontaudit signull from httpd process to libra_initrc_t domains
  (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Dontaudit leaked file descriptors for anon_inodefs, allow libra domains to
  connect to the flash port (dwalsh@redhat.com)

* Fri Mar 02 2012 Dan McPherson <dmcphers@redhat.com> 0.88.1-1
- bump spec numbers (dmcphers@redhat.com)
- remove 127.0.0.1 restrictions (mmcgrath@redhat.com)

* Wed Feb 29 2012 Dan McPherson <dmcphers@redhat.com> 0.87.6-1
- disabling hugetlbfs (mmcgrath@redhat.com)

* Wed Feb 29 2012 Dan McPherson <dmcphers@redhat.com> 0.87.5-1
- Dontaudit domains attempting to list /mnt, /dev/shm, and dontaudit leaked
  terminal device from sshd terminal to libra subdomains (dwalsh@redhat.com)
- Libra domains are creating /anon_hugepage  which are MCS Separated and then
  reading them, should be allowed (dwalsh@redhat.com)
- Allow libra domains to create msgq (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Dontaudit leaked terminal from sshd to libra_mail_t (dwalsh@redhat.com)

* Sat Feb 25 2012 Dan McPherson <dmcphers@redhat.com> 0.87.4-1
- Add new libra_app domains an libra file types (dwalsh@redhat.com)
- Allow libra_t to transition to ping command (dwalsh@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.87.3-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Libra directories contain a .tmp directory that is being bind mounted over
  the /tmp directory, we want to label this libra_tmp_t (dwalsh@redhat.com)

* Mon Feb 20 2012 Dan McPherson <dmcphers@redhat.com> 0.87.2-1
- Allow libra domains to create fifo_files in the libra_var_lib_t directory
  (dwalsh@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.87.1-1
- bump spec numbers (dmcphers@redhat.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.86.3-1
- There is a bug in sshd which we want to dontaudit dyntrans for libra domains
  for the time being. (dwalsh@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.2-1
- cleanup specs (dmcphers@redhat.com)
- Allow anon_inodefs_t writes so that Node processes/threads can communicate.
  (ramr@redhat.com)
- Changes to pam_libra and sshd requires that unconfined_t and libra domains
  can setcurrent, and unconfined_t needs to dyntrans (dwalsh@redhat.com)
- Move libra-proxy config file to /var/lib/libra/.libra-proxy.d
  (rmillner@redhat.com)
- rhc-selinux: forgot to require types (blentz@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Add dontaudit for people listing the contents of /dev, add debuginfo-install
  as an app that a user should not be allowed to execute (dwalsh@redhat.com)
- rhc-selinux: allow postfix and ntpd to bind to localhost (blentz@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Fix bugz 787060 - ioctl fails and that causes mongo shell to give no
  response. (ramr@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.86.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.85.9-1
- Re-enabling 127.0.0.1 ban (mmcgrath@redhat.com)
- Dontaudit getattr on any files, too much noise in logs, we are seeing a bogus
  setattr on /etc/mtab, that we should just ignore.  Started a list of apps
  that should have the o+x flag removed, since users try to execute these
  commands and generate AVC messages (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Allow httpd_t to ignore MCS labels, allow libra_mail_t to output to the
  inherited terminal (dwalsh@redhat.com)
- disabling remove (mmcgrath@redhat.com)
- fixing semanage (mmcgrath@redhat.com)
- disable allowing 127.0.0.1 binding (mmcgrath@redhat.com)
- Allow transitions from cron to libra user and enable death of children to be
  signalled back. (ramr@redhat.com)
- Re-add cron role - support cron runs. (ramr@redhat.com)
- More bug fixes. (ramr@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.8-1
- Dontaudit leaked file descriptors stdin/sdout from libra initrc domain to
  mail program (dwalsh@redhat.com)

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.7-1
- Add access to allow relabeling of privledged part of the openssh process
  (dwalsh@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.6-1
- Try out cron with libra domain (dwalsh@redhat.com)

* Wed Jan 18 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.5-1
- Fix typo. (ramr@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.85.4-1
- Checkpoint cron cartridge work. (ramr@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.3-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Allow sshd_t to mounton libra_tmp_t (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Fix to allow only libra_t access to postgres permissions (dwalsh@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- Revert "US1742, Add support for pop/imap (ports: 143, 220, 993, 109, 110,
  995)." (rmillner@redhat.com)
- US1742, Add support for pop/imap (ports: 143, 220, 993, 109, 110, 995).
  (rmillner@redhat.com)
