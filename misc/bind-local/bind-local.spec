Name:		bind-local
Version:	0.2
Release:	1%{?dist}
Summary:	Config for local named for test and development with Dynamic DNS
Group:		Network/Daemons
License:	GPLv2
URL:		http://openshift.redhat.com
Source0:	bind-local-${version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:	selinux-policy => 3.7.19-134
Requires:	selinux-policy-targeted >= 3.7.19-134
Requires(post): /usr/sbin/semanage
Requires(postun): /usr/sbin/semanage
Requires:	ruby
Requires:	bind

BuildArch: noarch

%description
This package provides configuration templates and a security policy module to
ease the creation of a local named service for testing DNS updates.

It provides both for a totally self-contained named service for simple
unit and functional testing, and an integrated system service which
allows client resolution of names in the test zone.

The package also includes an SELinux  security policy extension module to allow
forwarder updates from dhclient for hosts that get their IP/DNS information from
DHCP.

%prep
%setup -q


%build
cd ./%{_datadir}/selinux/packages
make -f /usr/share/selinux/devel/Makefile
rm -rf tmp

%install
# Install overlay files

# Install SELinux policy module
rm -rf $RPM_BUILD_ROOT
#make install DESTDIR=$RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT
cp -r etc usr %{buildroot}
mkdir -p %{buildroot}/var/named/dynamic
cp usr/share/bind-local/

%post
# Install the policy extension
/usr/sbin/semodule -i %{_datadir}/selinux/packages/dhcpnamedforward.pp || :

# determine if any interfaces use DHCP

# DHCP: No?

## flip SELinux dhcpnamedforward boolean off

## get forwarder from /etc/resolv.conf

## write forwarder file

## update /etc/resolv.conf

# DHCP: Yes?

## flip SELinux dhcpnamedforward boolean on 

## disable NetworkManager

## enable network

%preun
/usr/sbin/semodule -r dhcpnamedforward || :

%files
%doc
%defattr(0640,root,root,-)

# DHCP -> named forwarders 
/etc/dhclient.conf
%attr(0750,-,-) /etc/dhcp/dhclient-up-hooks

# script to start a self-contained named
%attr(0755,-,-) /usr/bin/named-local

# self-contained named config/template files
/usr/share/bind-local/example.com.db.init
/usr/share/bind-local/example.com.key
/usr/share/bind-local/Kexample.com.+157+06142.key
/usr/share/bind-local/Kexample.com.+157+06142.private

/usr/share/bind-local/self-contained-named.conf
/usr/share/bind-local/system-named.conf

# config files
/etc/named.conf

# 
/var/named/example.com.key

# dynamic files
/var/named/forwarders.conf
/var/named/dynamic/example.com.db

# SELinux files
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.te
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.fc
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.if
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.pp



%changelog
* Thu Mar 08 2012 Mark Lamourine <mlamouri@redhat.com> 0.2-1
- new package built with tito
- Configure a local named with dynamic DNS enabled for testing
- all non-local zones are forwarded to the first nameserver in /etc/resolv.conf
- handles interfaces configured with DHCP: updates forwarders on DHCP renew
