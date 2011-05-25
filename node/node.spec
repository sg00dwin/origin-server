%{!?ruby_sitelibdir: %global ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

Name: rhc-node
Version: 0.72.1
Release: 1%{?dist}
Summary: Multi-tenant cloud management system node tools
Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-node-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: quota
Requires: rhc-common
Requires: mcollective
Requires: rubygem-parseconfig
Requires: libcgroup
Requires: git
Requires: selinux-policy-targeted >= 3.7.19-83
Requires: rubygem-open4
Requires(post): /usr/sbin/semodule
Requires(post): /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule
Requires(postun): /usr/sbin/semanage

%description
Turns current host into a OpenShift managed node

%package tools
Summary: Utilities to help monitor and manage a OpenShift node
Group: Network/Daemons
BuildRequires: rubygem-nokogiri
BuildRequires: rubygem-json
Requires: rubygem-nokogiri
Requires: rubygem-json
BuildArch: noarch

%description tools
Status and control tools for Libra Nodes

%prep
%setup -q


%build
for f in **/*.rb
do
  ruby -c $f
done

%install
rm -rf $RPM_BUILD_ROOT

# MCollective setup
MCOLLECTIVE_DIR=$RPM_BUILD_ROOT/usr/libexec/mcollective/mcollective/agent
mkdir -p $MCOLLECTIVE_DIR
cp mcollective/libra.ddl $MCOLLECTIVE_DIR
chmod 0640 $MCOLLECTIVE_DIR/libra.ddl
cp mcollective/libra.rb $MCOLLECTIVE_DIR
chmod 0640 $MCOLLECTIVE_DIR/libra.rb
cp mcollective/update_yaml.pp $MCOLLECTIVE_DIR/../../
FACTER_DIR=$RPM_BUILD_ROOT/%{ruby_sitelibdir}/facter
mkdir -p $FACTER_DIR
cp "facter/libra.rb" $FACTER_DIR
chmod 0640 $FACTER_DIR/libra.rb

# Jailing setup
INITRD_DIR=$RPM_BUILD_ROOT/etc/init.d
mkdir -p $INITRD_DIR
cp scripts/libra $INITRD_DIR
chmod 0750 $INITRD_DIR/libra
cp scripts/libra-data $INITRD_DIR
chmod 0750 $INITRD_DIR/libra-data
cp scripts/libra-cgroups $INITRD_DIR
chmod 0750 $INITRD_DIR/libra-cgroups
cp scripts/libra-tc $INITRD_DIR
chmod 0750 $INITRD_DIR/libra-tc
BIN_DIR=$RPM_BUILD_ROOT/usr/bin
mkdir -p $BIN_DIR
cp scripts/trap-user $BIN_DIR
cp scripts/rhc-restorecon $BIN_DIR
chmod 0750 $BIN_DIR/rhc-restorecon
cp scripts/rhc-init-quota $BIN_DIR
chmod 0750 $BIN_DIR/rhc-init-quota
cp scripts/rhc-accept-node $BIN_DIR
chmod 0750 $BIN_DIR/rhc-accept-node
cp scripts/rhc-node-account $BIN_DIR
chmod 0750 $BIN_DIR/rhc-node-account
cp scripts/rhc-node-application $BIN_DIR
chmod 0750 $BIN_DIR/rhc-node-application
LIBRA_DIR=$RPM_BUILD_ROOT/var/lib/libra
mkdir -p $LIBRA_DIR
mkdir -p $RPM_BUILD_ROOT/usr/share/selinux/packages
cp selinux/libra.pp $RPM_BUILD_ROOT/usr/share/selinux/packages
chmod 0640 $RPM_BUILD_ROOT/usr/share/selinux/packages/libra.pp
cp selinux/rhc-ip-prep.sh $BIN_DIR
chmod 0750 $BIN_DIR/rhc-ip-prep.sh

# Apache vhost fix
HTTP_CONF_DIR=$RPM_BUILD_ROOT/etc/httpd/conf.d
mkdir -p $HTTP_CONF_DIR/libra/
chmod 0750 $HTTP_CONF_DIR/libra/
if [ ! -f "$HTTP_CONF_DIR/conf/000000_default.conf" ]
then
  cp conf/000000_default.conf $HTTP_CONF_DIR
fi
chmod 0640 $HTTP_CONF_DIR/000000_default.conf

# Cartridge installation
LIBEXEC_DIR=$RPM_BUILD_ROOT/usr/libexec/li
mkdir -p $LIBEXEC_DIR
cp -r cartridges $LIBEXEC_DIR
for dir in $LIBEXEC_DIR/cartridges/*
do
  chmod 0750 $dir/info/hooks/
  chmod 0750 $dir/info/data/
  chmod 0750 $dir/info/build/
done
CONF_DIR=$RPM_BUILD_ROOT/etc/libra
mkdir -p $CONF_DIR
SAMPLE_CONF=cartridges/li-controller-*/info/configuration/node.conf-sample
if [ ! -f "$CONF_DIR/node.conf" ]
then
  cp $SAMPLE_CONF $CONF_DIR/node.conf
fi
if [ ! -f "$CONF_DIR/resource_limits.conf" ]
then
  cp conf/resource_limits.conf $CONF_DIR
fi

# Tools installation
cd tools
rake package


mkdir -p .%{gemdir}
gem install --install-dir $RPM_BUILD_ROOT/%{gemdir} --bindir $RPM_BUILD_ROOT/%{_bindir} --local -V --force --rdoc \
     pkg/li-node-tools-%{version}.gem

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
/usr/sbin/semodule -i %_datadir/selinux/packages/libra.pp
/sbin/restorecon /etc/init.d/libra || :
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
if [ "$1" -eq 1 ]; then
    /sbin/service mcollective restart > /dev/null 2>&1 || :
fi
#/usr/sbin/semodule -r libra

%files
%defattr(-,root,root,-)
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/libra.ddl
%attr(0640,-,-) %{_libexecdir}/mcollective/mcollective/agent/libra.rb
%attr(0640,-,-) %{_libexecdir}/mcollective/update_yaml.pp
%attr(0640,-,-) %{ruby_sitelibdir}/facter/libra.rb
%attr(0750,-,-) %{_sysconfdir}/init.d/libra
%attr(0750,-,-) %{_sysconfdir}/init.d/libra-data
%attr(0750,-,-) %{_sysconfdir}/init.d/libra-cgroups
%attr(0750,-,-) %{_sysconfdir}/init.d/libra-tc
%attr(0750,-,-) %{_bindir}/rhc-ip-prep.sh
%attr(0755,-,-) %{_bindir}/trap-user
%attr(0750,-,-) %{_bindir}/rhc-restorecon
%attr(0750,-,-) %{_bindir}/rhc-init-quota
%dir %attr(0751,root,root) %{_localstatedir}/lib/libra
%dir %attr(0750,root,root) %{_libexecdir}/li/cartridges/li-controller-0.1/
%{_libexecdir}/li/cartridges/li-controller-0.1/README
%{_libexecdir}/li/cartridges/li-controller-0.1/info
%attr(0640,-,-) %{_datadir}/selinux/packages/libra.pp
%attr(0750,-,-) %{_bindir}/rhc-accept-node
%attr(0750,-,-) %{_bindir}/rhc-node-account
%attr(0750,-,-) %{_bindir}/rhc-node-application
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/libra/node.conf
%attr(0640,-,-) %config(noreplace) %{_sysconfdir}/libra/resource_limits.conf
%attr(0750,root,root) %config(noreplace) %{_sysconfdir}/httpd/conf.d/000000_default.conf
%attr(0640,root,root) %{_sysconfdir}/httpd/conf.d/libra

%files tools
%defattr(-,root,root,-)
%attr(0750,-,-) %{_bindir}/rhc-node-accounts
%attr(0750,-,-) %{_bindir}/rhc-node-apps
%attr(0750,-,-) %{_bindir}/rhc-node-status
%{gemdir}/gems/li-node-tools-%{version}
%{gemdir}/cache/li-node-tools-%{version}.gem
%{gemdir}/doc/li-node-tools-%{version}
%{gemdir}/specifications/li-node-tools-%{version}.gemspec