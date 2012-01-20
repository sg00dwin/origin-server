Summary:       SELinux policy for OpenShift nodes
Name:          rhc-selinux
Version:       0.85.7
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-selinux-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: selinux-policy >= 3.7.19-134
Requires:      selinux-policy-targeted >= 3.7.19-134
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
/usr/sbin/semodule -i %{_datadir}/selinux/packages/libra.pp

# Bring in external smtp ports but _NOT_ 25.
#semanage -i - << _EOF
#port -m -t libra_port_t -p tcp 465
#port -m -t libra_port_t -p tcp 587
#_EOF

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_datadir}/selinux/packages/libra.pp

%changelog
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

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.84.13-1
- Remove temporary addition of port 8787 to the jboss mgmt port list and use
  jboss_debug_port_t from the updated selinux-policy-3.7.19-134 package.
  (ramr@redhat.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.84.12-1
- Move the temp add of jboss debug port to selinux.spec as install.sh is only
  run locally. Should fix bugz 772547. (ramr@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.11-1
- Allow libra domains to use tmpfs_t files if handed to it by the kernel, shm,
  do not allow open or create (dwalsh@redhat.com)
- Allow libra domains to create shared memory (dwalsh@redhat.com)
- Allow libra domains to execute postgresql_exec_t (dwalsh@redhat.com)
- Fix support for postgresql (dwalsh@redhat.com)

* Thu Jan 05 2012 Dan McPherson <dmcphers@redhat.com> 0.84.10-1
- Seems like build is still failing because we have : selinux-
  policy-3.7.19-131.el6 installed and not selinux-policy-3.7.19-133.el6 [131 in
  lieu of 133]. So Dan, commenting the line causing failure for now.
  (ramr@redhat.com)
- Revert temporary comment as it is failing locally [but build seems to be ok].
  (ramr@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Bug fixes to get postgresql working for US1386. As of now php, python and
  perl drivers are working fine. Drivers for java and ruby are still pending.
  (ramr@redhat.com)

* Thu Jan 05 2012 Dan McPherson <dmcphers@redhat.com> 0.84.9-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Since selinux-policy-3.7.19-133.el6 has been pulled into libra I am removing
  extra policy and turning on dontaudit for setattr on /etc/fstab.  Also
  removing permissive flag from libra_mail_t (dwalsh@redhat.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.84.8-1
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- initial checkin for US1614 -- jboss remote debugging ports. (ramr@redhat.com)

* Wed Jan 04 2012 Alex Boone <aboone@redhat.com> 0.84.7-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Converting /etc/httpd/conf.d/ to a symlink (mmcgrath@redhat.com)

* Wed Jan 04 2012 Alex Boone <aboone@redhat.com> 0.84.6-1
- More fixes for avc's generated by allowing libra domains to send mail Version
  27 (dwalsh@redhat.com)
- Up version (dwalsh@redhat.com)
- Allow mta user agents to send sigchld to libra domains (dwalsh@redhat.com)

* Tue Jan 03 2012 Dan McPherson <dmcphers@redhat.com> 0.84.5-1
- Version 25 dontaudit getaddr of any directory,  running simple probes with ls
  generate hundreds of these, which I just ignore (dwalsh@redhat.com)
- Version 24 dontaudit getcap, which can be triggered by using ls command and
  probing (dwalsh@redhat.com)

* Thu Dec 29 2011 Dan McPherson <dmcphers@redhat.com> 0.84.4-1
- Allow zibra domains to create fifo_files in /tmp, allow libra domains to
  relabelfrom/to libra_tmp_t and libra_var_lib_t (dwalsh@redhat.com)

* Wed Dec 21 2011 Mike McGrath <mmcgrath@redhat.com> 0.84.3-1
- require selinux policy 131 (mmcgrath@redhat.com)
- Dontaudit libra domains searching ssh_home_t (dwalsh@redhat.com)
- Add policy for libra_var_run_t (dwalsh@redhat.com)
- Add tmp file for librar init script to setup log file (dwalsh@redhat.com)
- Dontaudit libra domains searching ssh_home_t (dwalsh@redhat.com)

* Tue Dec 20 2011 Mike McGrath <mmcgrath@redhat.com> 0.84.2-1
- Adding pop/imap ports (mmcgrath@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.84.1-1
- bump spec numbers (dmcphers@redhat.com)

* Tue Dec 13 2011 Dan McPherson <dmcphers@redhat.com> 0.83.11-1
- Bumb the version so I have an idea of what is installed (dwalsh@redhat.com)
- Add libra_port_t to allow libra domains to connect to reassigned ports, like
  some of the smtp_ports (dwalsh@redhat.com)

* Mon Dec 12 2011 Dan McPherson <dmcphers@redhat.com> 0.83.10-1
- Use the RHEL supplied policy for allowing connections to smtp.
  (rmillner@redhat.com)
- Revert "Allow libra applications to make outbound connnections to the
  submission port." (rmillner@redhat.com)

* Sun Dec 11 2011 Dan McPherson <dmcphers@redhat.com> 0.83.9-1
- disabling libra_port_t (mmcgrath@redhat.com)

* Sun Dec 11 2011 Dan McPherson <dmcphers@redhat.com> 0.83.8-1
- add require for semanage (dmcphers@redhat.com)

* Thu Dec 08 2011 Alex Boone <aboone@redhat.com> 0.83.7-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Allow libra applications to make outbound connnections to the submission
  port. (rmillner@redhat.com)
- Allowing outbound smtp (mmcgrath@redhat.com)

* Wed Dec 07 2011 Mike McGrath <mmcgrath@redhat.com> 0.83.6-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- correcting selinux for real this time (mmcgrath@redhat.com)

* Wed Dec 07 2011 Mike McGrath <mmcgrath@redhat.com> 0.83.5-1
- changing requires (mmcgrath@redhat.com)

* Wed Dec 07 2011 Matt Hicks <mhicks@redhat.com> 0.83.4-1
- Fix libra transition to libra_mail_t (dwalsh@redhat.com)
- Allow libra domains to transition to libra_mail_t domain for sending mail
  over executables labeled sendmail_exec_t (dwalsh@redhat.com)

* Tue Dec 06 2011 Alex Boone <aboone@redhat.com> 0.83.3-1
- Adding munin port (mmcgrath@redhat.com)

* Fri Dec 02 2011 Dan McPherson <dmcphers@redhat.com> 0.83.2-1
- Allow libra domains to relabelfrom libra_var_lib_t  so if they run vi, it
  will not complain (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- properly labeling new restorer scripts (mmcgrath@redhat.com)

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.83.1-1
- bump spec numbers (dmcphers@redhat.com)
- Allow libra_initrc_t to set categories on processes (dwalsh@redhat.com)
- Fixes to allow libra domains to work with oddjob (dwalsh@redhat.com)

* Wed Nov 30 2011 Dan McPherson <dmcphers@redhat.com> 0.81.10-1
- fix type on policy (dwalsh@redhat.com)
- Add httpd_libra_script_t policy to allow httpd to talk to oddjob and start up
  libra domains (dwalsh@redhat.com)

* Wed Nov 30 2011 Dan McPherson <dmcphers@redhat.com> 0.81.9-1
- Allow libra initrc script to be started by oddjob (dwalsh@redhat.com)

* Wed Nov 23 2011 Dan McPherson <dmcphers@redhat.com> 0.81.8-1
- Allow connection to mongo port (mmcgrath@redhat.com)

* Mon Nov 21 2011 Dan McPherson <dmcphers@redhat.com> 0.81.7-1
- allow sysctl reading (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- selinux policy increment (mmcgrath@redhat.com)

* Mon Nov 21 2011 Dan McPherson <dmcphers@redhat.com> 0.81.6-1
-

* Mon Nov 21 2011 Dan McPherson <dmcphers@redhat.com> 0.81.5-1
- Add support for mongod, requires selinux-policy-3.7.19-129.el6
  (dwalsh@redhat.com)

* Thu Nov 17 2011 Dan McPherson <dmcphers@redhat.com> 0.81.4-1
- Dontaudit listing of /proc withing the libra domains (dwalsh@redhat.com)

* Wed Nov 16 2011 Dan McPherson <dmcphers@redhat.com> 0.81.3-1
- Additional dontaudit lines to suppress bogus AVC's (dwalsh@redhat.com)

* Sat Nov 12 2011 Dan McPherson <dmcphers@redhat.com> 0.81.2-1
- Remove java command, covered by application_exec, allow libra domains to make
  tmp link files (dwalsh@redhat.com)

* Thu Oct 27 2011 Dan McPherson <dmcphers@redhat.com> 0.81.1-1
- bump spec numbers (dmcphers@redhat.com)

* Tue Oct 25 2011 Dan McPherson <dmcphers@redhat.com> 0.80.6-1
- Allow libra_cgroup_read_t to use inherited fifo_file from libra_initrc_t.
  stdin, stdout and stderr (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Allow libra_cgroup_read_t to execute bin and read cert files
  (dwalsh@redhat.com)
- correcting miscfiles interface (mmcgrath@redhat.com)
- Add dontaudit for libra_domain trying to setattr on the fonts_cache_t file,
  this would be blocked by DAC anyways, but kernel must be doing the SELinux
  check first.  Also the way we are disabling IPV6 is causing lots of domains
  to ask the kernel to load the IPV6 kernel module,  Adding a dontaudit for
  this until we change the way the IPV6 is disabled. (dwalsh@redhat.com)

* Mon Oct 24 2011 Dan McPherson <dmcphers@redhat.com> 0.80.5-1
- altering ~/.ssh access (mmcgrath@redhat.com)

* Mon Oct 24 2011 Dan McPherson <dmcphers@redhat.com> 0.80.4-1
-

* Fri Oct 21 2011 Dan McPherson <dmcphers@redhat.com> 0.80.3-1
- Allow sshd_t to remove libra_tmp_t directories, also allow libra_domains to
  send signals to the libra_cgroup domains (dwalsh@redhat.com)

* Mon Oct 17 2011 Dan McPherson <dmcphers@redhat.com> 0.80.2-1
- libra_cgroup_read needs to read certificates (dwalsh@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.80.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.79.6-1
- Turn off permissive domain in production. (dwalsh@redhat.com)
- rhc-cgroup-read needs to read content in the libra_var_lib directory as well
  as certificates (dwalsh@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.5-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Correcting comment error (mmcgrath@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.4-1
- Allow libra domains to connect to ephemeral ports defined as virt_migration
  (dwalsh@redhat.com)
- Allow libra domains to getattr on ssh_home_t, requires selinux-policy-
  doc-3.7.19-116.el6 now in brew or people.redhat.com/dwalsh/SELinux/RHEL6
  (dwalsh@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.79.3-1
- allowing libra_tmp_t (mmcgrath@redhat.com)
- diabling for build (mmcgrath@redhat.com)
- Allow libra domains to communcate with sshd over a sock_file
  (dwalsh@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.79.2-1
- Allow all unconfined domains to transition to libra_t, also allowing libra_t
  to send sigchld to unconfined_java_t (dwalsh@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.79.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Sep 22 2011 Dan McPherson <dmcphers@redhat.com> 0.78.3-1
- Allow libra domains to search /var/www/cgi-bin directory and other similarly
  labeled directories.  I am adding a new interface to allow libra domains to
  execut cgi scripts in the libra_t domain. Will update as soon as this becomes
  available (dwalsh@redhat.com)

* Fri Sep 09 2011 Matt Hicks <mhicks@redhat.com> 0.78.2-1
- Allow libra domains to execute user apps like ifconfig and hostname, this
  does not add priv since it stays within the same domain (dwalsh@redhat.com)
- Since libra domains can connect to ssh_port_t, I will allow them to execut
  ssh (dwalsh@redhat.com)
- Allow libra to connect to oracle ports (dwalsh@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.78.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Aug 31 2011 Dan McPherson <dmcphers@redhat.com> 0.77.8-1
- Allow libra domains to connect to postgresql ports (dwalsh@redhat.com)
- Allow libra domains to connect to mssql ports (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Allow libra_t to connect to git port and allow all libra domains to read man
  pages (dwalsh@redhat.com)

* Tue Aug 30 2011 Dan McPherson <dmcphers@redhat.com> 0.77.7-1
-

* Tue Aug 30 2011 Dan McPherson <dmcphers@redhat.com> 0.77.6-1
-

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.77.5-1
- Update to use newer RHEL6.2 policy.  selinux-policy-3.7.19-108.el6 required
  (dwalsh@redhat.com)
- Fix quota transition rule (dwalsh@redhat.com)
- Allow quota to be stored in libra filesystems (dwalsh@redhat.com)

* Thu Aug 25 2011 Dan McPherson <dmcphers@redhat.com> 0.77.4-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Allow sshd connects (mmcgrath@redhat.com)

* Wed Aug 24 2011 Dan McPherson <dmcphers@redhat.com> 0.77.3-1
- puppet is leaking file descriptors to domains that it is restarting
  (dwalsh@redhat.com)

* Wed Aug 24 2011 Dan McPherson <dmcphers@redhat.com> 0.77.2-1
- Add libra_croup_read_t domain to allow the libra domains to execute rhc-
  cgroup-read script.  This will allow libr domains to see only their cgroup
  values and continue to block them from other cgroup values.
  (mmcgrath@redhat.com)
- Add libra_croup_read_t domain to allow the libra domains to execute rhc-
  cgroup-read script.  This will allow libr domains to see only their cgroup
  values and continue to block them from other cgroup values.
  (mmcgrath@redhat.com)
- Remove gen_require info that has been implemented in the latest 6.2 selinux-
  policy package interfaces (dwalsh@redhat.com)

* Fri Aug 19 2011 Matt Hicks <mhicks@redhat.com> 0.77.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.5-1
- disable cgroup reads for now (mmcgrath@redhat.com)

* Tue Aug 16 2011 Matt Hicks <mhicks@redhat.com> 0.76.4-1
- Allow libra domains to read cgroup data (dwalsh@redhat.com)

* Fri Aug 12 2011 Matt Hicks <mhicks@redhat.com> 0.76.3-1
- Seems like jboss running lsof and this is causing avcs looking at sockets and
  dirs within /var/run directory. (dwalsh@redhat.com)

* Mon Aug 08 2011 Dan McPherson <dmcphers@redhat.com> 0.76.2-1
- Added dontaudit rules for common commands quota, df, uptime, Also allowing
  libra_t to exec libra_tmp_t, for mmap files. This will allow users to execute
  files they create.  But I think it would be legitimate for some apps to need
  the ability to mmap memory. One app attempted to signul is parents, I will
  just dontaudit this, I dont want signals being sent to the libra_initrc_t
  process (dwalsh@redhat.com)

* Fri Aug 05 2011 Dan McPherson <dmcphers@redhat.com> 0.76.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Aug 03 2011 Dan McPherson <dmcphers@redhat.com> 0.75.9-1
- adding selinux proper requires (mmcgrath@redhat.com)
- require newer version of selinux (mmcgrath@redhat.com)

* Tue Aug 02 2011 Dan McPherson <dmcphers@redhat.com> 0.75.8-1
-

* Tue Aug 02 2011 Dan McPherson <dmcphers@redhat.com> 0.75.7-1
- Allow libra_t domains to connect to the ftp port (dwalsh@redhat.com)

* Mon Aug 01 2011 Dan McPherson <dmcphers@redhat.com> 0.75.6-1
-

* Sun Jul 31 2011 Dan McPherson <dmcphers@redhat.com> 0.75.5-1
-

* Thu Jul 28 2011 Dan McPherson <dmcphers@redhat.com> 0.75.4-1
- Allow libra to connect to memcache port (dwalsh@redhat.com)

* Fri Jul 22 2011 Dan McPherson <dmcphers@redhat.com> 0.75.3-1
- Comment out fs_dontaudit_search_cgroup_dirs, until it shows up in RHEL6
  (dwalsh@redhat.com)

* Fri Jul 22 2011 Dan McPherson <dmcphers@redhat.com> 0.75.2-1
- Dontaudit libra domains executing ls / (dwalsh@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.1-1
- Allow socket management in /tmp (mmcgrath@redhat.com)
- bump spec numbers (dmcphers@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.4-1
- Allow libra_t to use gpg_exec_t as an entrypoint.  Define libra_var_lib_t as
  a poly_parent, so login domains can relabelfrom this label
  (dwalsh@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.3-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- bumping release (mmcgrath@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.74.2-1
- Automatic commit of package [rhc-selinux] release [0.74.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- Automatic commit of package [rhc-selinux] release [0.73.4-1].
  (dmcphers@redhat.com)
- Dontaudit the fifo_file passing to other domains from libra_t
  (dwalsh@redhat.com)
- Make libra_var_lib_t a files_poly() to allow it to be polyinstatiated by sshd
  (dwalsh@redhat.com)
- removing un-needed selinux allowance (mmcgrath@redhat.com)
- Automatic commit of package [rhc-selinux] release [0.73.3-1].
  (dmcphers@redhat.com)
- fixed selinux module (mmcgrath@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.74.1-1
- bumping spec numbers (dmcphers@redhat.com)

* Tue Jul 05 2011 Dan McPherson <dmcphers@redhat.com> 0.73.4-1
- Dontaudit the fifo_file passing to other domains from libra_t
  (dwalsh@redhat.com)
- Make libra_var_lib_t a files_poly() to allow it to be polyinstatiated by sshd
  (dwalsh@redhat.com)
- removing un-needed selinux allowance (mmcgrath@redhat.com)

* Thu Jun 30 2011 Dan McPherson <dmcphers@redhat.com> 0.73.3-1
- fixed selinux module (mmcgrath@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.2-1
-

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.9-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Dontaudit libra domains from search of getattr on ssh_home_t
  (dwalsh@redhat.com)

* Wed Jun 15 2011 Dan McPherson <dmcphers@redhat.com> 0.72.8-1
- Allow tail to run in a libra domain (dwalsh@redhat.com)

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.7-1
- Removing fc list for testing (mmcgrath@redhat.com)

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.6-1
- Allow sshd_t to interact with libra_domains (dwalsh@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Allow libra domain to be entered from bin_t types (dwalsh@redhat.com)
- removing dup bind (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (dwalsh@redhat.com)
- Allow libra to bind to jboss_management port (dwalsh@redhat.com)
- Adding bind for jboss (mmcgrath@redhat.com)
- Permanent jboss fix now in place (mmcgrath@redhat.com)
- Allow libra_t to connect to jboss_management port (dwalsh@redhat.com)
- Adjust for permissions (jimjag@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.5-1
- Allow domains to search through libra_var_lib_t, allow libra domains to
  search tmpfs, dontaudit libra_domains trying to create audit sockets, this
  happens when the launch bash (dwalsh@redhat.com)
- Allow libra domain to execute files labeled lib_t (dwalsh@redhat.com)

* Wed Jun 08 2011 Matt Hicks <mhicks@redhat.com> 0.72.4-1
- adding libra.te (mmcgrath@redhat.com)
- Adding back local install script (mhicks@redhat.com)
- Allow unconfined_t to become libra_t (dwalsh@redhat.com)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.3-1
- Tighten up security on append, so only inherited files can be appended.
  (dwalsh@redhat.com)
- Allow all domains to append to librar_var_lib_t, Log Files
  (dwalsh@redhat.com)

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-4
- Creating necessary buildroot dirs

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-3
- Adding selinux policy to build requires

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-2
- Actually building policy in RPM

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- More SELinux file reshuffling (mhicks@redhat.com)

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
