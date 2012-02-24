Summary:       SELinux policy for OpenShift development nodes 
Name:          rhc-selinux-devenv
Version:       0.1.0
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-selinux-devenv-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: selinux-policy >= 3.7.19-134
Requires:      selinux-policy-targeted >= 3.7.19-134
Requires(post):   /usr/sbin/semanage
Requires(postun): /usr/sbin/semanage

BuildArch: noarch

%description
Supplies the SELinux policy for the OpenShift development nodes.
1) Allows dhclient to write a file: /var/named/forwarders.conf
   This file can be read by named so that DNS resolution is handled correctly
   when the development system is running local named and the primary network
   interface gets its information from DHCP

%prep
%setup -q

%build
make -f /usr/share/selinux/devel/Makefile

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_datadir}/selinux/packages
cp dhcpnamedforward.pp %{buildroot}%{_datadir}/selinux/packages/dhcpnamedforward.pp

%clean
rm -rf %{buildroot}

%post
/usr/sbin/semodule -i %{_datadir}/selinux/packages/dhcpnamedforward.pp || :

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.pp

%changelog
* Fri Feb 24 2012 Dan McPherson <dmcphers@redhat.com> 0.1.0-0
- Allow dhclient to write /var/named/forwarders.conf
  Allow named to read it to include in local service configuration

