Name: bind-local
Version:	0.9.2
Release:	1%{?dist}
Summary:	Config for local named for test and development with Dynamic DNS
Group:		Network/Daemons
License:	GPLv2
URL:		http://openshift.redhat.com
Source0:	bind-local-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:	selinux-policy => 3.7.19-134
Requires:	selinux-policy-targeted >= 3.7.19-134
Requires(post): /usr/sbin/semodule
Requires(postun): /usr/sbin/semodule
Requires:	bind
Requires:	policycoreutils

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
cp -r etc usr var %{buildroot}


%post
# Install the policy extension
/usr/sbin/semodule -i %{_datadir}/selinux/packages/dhcpnamedforward.pp || :

# determine if any interfaces use DHCP
DHCP_INTERFACES=`grep -e ^BOOTPROTO=\"dhcp\" /etc/sysconfig/network-scripts/ifcfg-* | sed -e 's/:.*$//;'`

# disable NetworkManager from any DHCP interfaces
if [ -n "${DHCP_INTERFACES}" ]
then
  for IF_FILE in $DHCP_INTERFACES
  do
    sed -i -e '/NM_CONTROLLED/s/yes/no/' ${IF_FILE}
  done
fi

# preserve the existing named config
if [ ! -f /etc/named.conf.orig ]
then
  mv /etc/named.conf /etc/named.conf.orig
fi
# install the local server named
cp /usr/share/bind-local/etc/named.conf /etc/named.conf
chown root:named /etc/named.conf
restorecon -v /etc/named.conf

# get the first resolver from /etc/resolv.conf
FORWARDER=`grep nameserver /etc/resolv.conf | head -1 | cut -d' ' -f2`

# insert localhost before the first nameserver line
sed -i -e '1,/nameserver/ { /nameserver/ i\
/nameserver 127.0.0.1
}' /etc/resolv.conf

# Set up the initial forwarder
echo "forwarders { ${FORWARDER} ; } ;" > /var/named/forwarders.conf

# set SELinux label for forwarders file
restorecon -v /var/named/forwarders.conf

# Enable and start local named
chkconfig named on
service named start

# disable NetworkManager
if chkconfig NetworkManager
then
  chkconfig NetworkManager off
  chkconfig network on
else
  service network on
  service network restart
fi

if [ ! -f /etc/named.conf.orig ]
then
  mv /etc/named.conf /etc/named.conf.orig
fi


%preun
# Just unconfigure.  DON'T RESTART

service named stop
chkconfig named off

# remove dynamic files
rm -f /var/named/dynamic/*

# remove localhost from /etc/resolv.conf
sed -i -e '/nameserver 127.0.0.1/d' /etc/resolv.conf

# restore the original named.conf
if [ -f /etc/named.conf.orig ]
then
  mv /etc/named.conf.orig /etc/named.conf
fi

# Find the interfaces that depend on DHCP
DHCP_INTERFACES=`grep -e ^BOOTPROTO=\"dhcp\" /etc/sysconfig/network-scripts/ifcfg-* | sed -e 's/:.*$//;'`

if rpm -q NetworkManager > /dev/null
then
  chkconfig network off
  chkconfig NetworkManager on

  # Enable NetworkManager on all DHCP interfaces
  if [ -n "${DHCP_INTERFACES}" ]
  then
    for IF_FILE in ${DHCP_INTERFACES}
    do
      sed -i -e '/NM_CONTROLLED/s/no/yes/' ${IF_FILE}
    done
  fi
fi

%postun
# really remove 
# disable and remove the SELinux policy extension
/usr/sbin/semodule -r dhcpnamedforward || :

# Find the interfaces that depend on DHCP
DHCP_INTERFACES=`grep -e ^BOOTPROTO=\"dhcp\" /etc/sysconfig/network-scripts/ifcfg-* | sed -e 's/:.*$//;'`
if [ -n "DHCP_INTERFACES" ]
then
  # start NetworkManager if it's present and enabled
  if chkconfig NetworkManager
  then
    service network stop
    service NetworkManager start
  else
    service network restart
  fi
fi

%files
%doc README
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

/usr/share/bind-local/named.conf

# config files
# named.conf is copied to avoid conflict with bind RPM 
# %config /etc/named.conf
/usr/share/bind-local/etc/named.conf

# system service config files
%config %attr(0640,root,named) /var/named/example.com.key
%config %attr(0640,root,named) /var/named/dynamic/example.com.db
#%config %attr(0640,root,named) /var/named/forwarders.conf
%attr(0640,root,named) /var/named/forwarders.conf

# SELinux files
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.te
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.fc
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.if
%attr(0640,-,-) %{_datadir}/selinux/packages/dhcpnamedforward.pp



%changelog
* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.9.2-1
- 

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.9.1-1
- new package built with tito

* Tue Mar 13 2012 Mark Lamourine <mlamouri@redhat.com> 0.9-1
- fixed $var in spec to %%var (mlamouri@redhat.com)
- Automatic commit of package [bind-local] release [0.8-1].
  (mlamouri@redhat.com)

* Tue Mar 13 2012 Mark Lamourine <mlamouri@redhat.com> 0.8-1
- cd on start to get logs placed properly (mlamouri@redhat.com)
- fixed location of named-local init files (mlamouri@redhat.com)

* Mon Mar 12 2012 Mark Lamourine <mlamouri@redhat.com> 0.7-1
- Finish packaging bind-local:   install named configuration files   install
  dhcpnamedforward SELinux policy   install dhclient config and hooks to
  generate resolv.conf and forwarders   Convert named-local script to bourne
  shell   Drop dependency on ruby for named-local service control
  (mlamouri@redhat.com)

* Fri Mar 09 2012 Mark Lamourine <mlamouri@redhat.com> 0.3-1
- comment forwarders for now (mlamouri@redhat.com)
- dynamic belongs under var/named (mlamouri@redhat.com)
- move files into correct places in var (mlamouri@redhat.com)
- rename to make room for dir (mlamouri@redhat.com)
- save this, but dont install it (mlamouri@redhat.com)
- script names use hyphens (mlamouri@redhat.com)
- just add var stuff instead of iccky copy (mlamouri@redhat.com)
- added system named initializers (mlamouri@redhat.com)
- since its copied to /etc its not needed here (mlamouri@redhat.com)
- correct name in share and place the system named.conf correctly
  (mlamouri@redhat.com)
- remove tmp dir after policy build, copy etc and usr, create var
  (mlamouri@redhat.com)
- remove tmp dir after policy build, copy var and usr (mlamouri@redhat.com)
- go to the right directory to build policy (mlamouri@redhat.com)
- build selinux extension module (mlamouri@redhat.com)
- start filling in %%install steps (mlamouri@redhat.com)
- Automatic commit of package [bind-local] release [0.2-1].
  (mlamouri@redhat.com)

* Thu Mar 08 2012 Mark Lamourine <mlamouri@redhat.com> 0.2-1
- new package built with tito
- Configure a local named with dynamic DNS enabled for testing
- all non-local zones are forwarded to the first nameserver in /etc/resolv.conf
- handles interfaces configured with DHCP: updates forwarders on DHCP renew
