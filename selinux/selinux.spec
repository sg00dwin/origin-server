Summary:       SELinux policy for OpenShift nodes
Name:          rhc-selinux
Version:       0.76.2
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-selinux-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: selinux-policy >= 3.7.19-106
Requires:      selinux-policy-targeted >= 3.7.19-106

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

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_datadir}/selinux/packages/libra.pp

%changelog
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
