Summary:       SELinux policy for OpenShift nodes
Name:          rhc-selinux
Version: 0.93.5
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-selinux-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: selinux-policy >= 3.7.19-150
Requires:      selinux-policy-targeted >= 3.7.19-150
Requires(post):   /usr/sbin/semanage
Requires(postun): /usr/sbin/semanage

BuildArch: noarch

%description
Supplies the SELinux policy for the OpenShift nodes

%prep
%setup -q

%build
make -f /usr/share/selinux/devel/Makefile

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_datadir}/selinux/packages
cp libra.pp %{buildroot}%{_datadir}/selinux/packages/libra.pp

%clean
rm -rf %{buildroot}

%post
/usr/sbin/semodule -i %{_datadir}/selinux/packages/libra.pp || :

# Bring in external smtp ports but _NOT_ 25.
#semanage -i - << _EOF
#port -m -t libra_port_t -p tcp 465
#port -m -t libra_port_t -p tcp 587
#_EOF

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_datadir}/selinux/packages/libra.pp

%changelog
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
