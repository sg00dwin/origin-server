Summary:       SELinux policy for OpenShift nodes
Name:          rhc-selinux
Version:       0.72.9
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-selinux-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: selinux-policy
Requires:      selinux-policy-targeted >= 3.7.19-94

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
