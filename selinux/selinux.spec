Summary:       SELinux policy for OpenShift nodes
Name:          rhc-selinux
Version:       0.72.2
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-selinux-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:      selinux-policy-targeted >= 3.7.19-94
Requires(post):   /usr/sbin/semodule
Requires(post):   /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule
Requires(postun): /usr/sbin/semanage

BuildArch: noarch

%description
Supplies the SELinux policy for the OpenShift nodes

%prep
%setup -q

%build
make -f /usr/share/selinux/devel/Makefile

%install
rm -rf %{_buildroot}
cp libra.pp %{_datadir}/selinux/packages/libra.pp

%clean
rm -rf %{_buildroot}

%post
/usr/sbin/semodule -i %{_datadir}/selinux/packages/libra.pp

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_datadir}/selinux/packages/libra.pp

%changelog
* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- More SELinux file reshuffling (mhicks@redhat.com)

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
