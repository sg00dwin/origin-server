%{!?ruby_sitelibdir: %global ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

Name: li
Version: 0.59.1
Release: 1%{?dist}
Summary: Multi-tenant cloud management system client tools

Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: li-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

BuildRequires: rubygem-rake
BuildRequires: rubygem-rspec
Requires: ruby >= 1.8.7
Requires: rubygem-parseconfig
Requires: rubygem-json
Requires: git

%description
Provides Li client libraries

%package devenv
Summary: Dependencies for Libra development
Group: Development/Libraries
Requires: li
Requires: li-common
Requires: li-node
Requires: li-server
Requires: li-cartridge-php-5.3.2
Requires: li-cartridge-wsgi-3.2.1
Requires: li-cartridge-rack-1.1.0
Requires: qpid-cpp-server
BuildArch: noarch

%description devenv
Provides all the development dependencies to be able to run the libra tests

%package common
Summary: Common dependencies of the libra server and node
Group: Network/Daemons
Requires: mcollective-client
Requires: qpid-cpp-client
Requires: ruby-qmf
BuildArch: noarch

%description common
Provides the common dependencies for the libra server and nodes

%package node
Summary: Multi-tenant cloud management system node tools
Group: Network/Daemons
Requires: li-common
Requires: mcollective
Requires: rubygem-parseconfig
Requires: libcgroup
Requires: git
Requires(post): /usr/sbin/semodule
Requires(post): /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule
Requires(postun): /usr/sbin/semanage
BuildArch: noarch

%description node
Turns current host into a Li managed node

%package node-tools
Summary: Utilities to help monitor and manage a Li node
Group: Network/Daemons
BuildRequires: rubygem-nokogiri
BuildRequires: rubygem-json
Requires: rubygem-nokogiri
BuildArch: noarch

%description node-tools
Status and control tools for Libra Nodes

%package server
Summary: Li server components
Group: Network/Daemons
Requires: li-common
BuildArch: noarch
Requires: httpd
Requires: ruby
Requires: rubygems
Requires: rubygem-aws
Requires: rubygem-rack = 1:1.1.0
Requires: rubygem-passenger
Requires: rubygem-passenger-native
Requires: rubygem-passenger-native-libs
Requires: mod_passenger
Requires: rubygem-sqlite3-ruby
Requires: ruby-sqlite3
Requires: rubygem-bundler

%description server
This contains the server 'controlling' components of Li.  This can be on the
same host as a node.  It also contains the rails site and public APIs.

Note: to use this you'll need qpid installed somewhere.  It doesn't have
to be the same host as the server.  It is the 'qpid-cpp-server' package.

%package cartridge-php-5.3.2
Summary: Provides php-5.3.2 support
Group: Development/Languages
Requires: li-node
Requires: php = 5.3.2
Requires: mod_bw
Requires: rubygem-builder
Requires: php-pdo
Requires: php-gd
Requires: php-xml
Requires: php-mysql
BuildArch: noarch

%description cartridge-php-5.3.2
Provides php support to li

%package cartridge-rack-1.1.0
Summary: Provides ruby rack support running on Phusion Passenger
Group: Development/Languages
Requires: li-node
Requires: httpd
Requires: mod_bw
Requires: ruby
Requires: rubygems
Requires: rubygem-rack = 1:1.1.0
Requires: rubygem-passenger
Requires: rubygem-passenger-native
Requires: rubygem-passenger-native-libs
Requires: mod_passenger
Requires: rubygem-bundler
Requires: rubygem-sqlite3-ruby
Requires: ruby-sqlite3
Requires: ruby-mysql
BuildArch: noarch

%description cartridge-rack-1.1.0
Provides rack support to li

%package cartridge-wsgi-3.2.1
Summary: Provides python-wsgi-3.2.1 support
Group: Development/Languages
Requires: li-node
Requires: httpd
Requires: mod_bw
Requires: python
Requires: mod_wsgi = 3.2
BuildArch: noarch

%description cartridge-wsgi-3.2.1
Provides wsgi support to li

%prep
%setup -q


%build
rake install:test:all

%install
rm -rf $RPM_BUILD_ROOT
rake DESTDIR="$RPM_BUILD_ROOT" install:all
ln -s %{_localstatedir}/www/html/libra/public $RPM_BUILD_ROOT/%{_localstatedir}/www/html/app

mkdir $RPM_BUILD_ROOT/etc/libra/devenv/
cp -adv docs/devenv/* $RPM_BUILD_ROOT/etc/libra/devenv/

mkdir -p .%{gemdir}
gem install --install-dir $RPM_BUILD_ROOT/%{gemdir} --bindir $RPM_BUILD_ROOT/%{_bindir} --local -V --force --rdoc \
     client/pkg/li-%{version}.gem
gem install --install-dir $RPM_BUILD_ROOT/%{gemdir} --bindir $RPM_BUILD_ROOT/%{_bindir} --local -V --force --rdoc \
     node/tools/pkg/li-node-tools-%{version}.gem

%clean
rm -rf $RPM_BUILD_ROOT


%post devenv
# qpid
/bin/cp -f /etc/libra/devenv/qpidd.conf /etc/qpidd.conf
service qpidd restart
chkconfig qpidd on

# mcollective
/bin/cp -f /etc/libra/devenv/client.cfg /etc/libra/devenv/server.cfg /etc/mcollective
service mcollective start
chkconfig mcollective on

# iptables
/bin/cp -f /etc/libra/devenv/iptables /etc/sysconfig/iptables
/etc/init.d/iptables restart

# Adding passenger user
useradd libra_passenger -g libra_user -d /var/lib/passenger -r -s /sbin/nologin

# enable development environment
/bin/sed -i 's/#RailsEnv/RailsEnv/g' /etc/httpd/conf.d/rails.conf

# httpd
/etc/init.d/httpd restart
chkconfig httpd on

# Allow httpd to relay
/usr/sbin/setsebool -P httpd_can_network_relay=on || :

# Setup facts
/usr/bin/puppet /usr/libexec/mcollective/update_yaml.pp
crontab -u root /etc/libra/devenv/crontab

# Libra
/bin/cp -f /etc/libra/devenv/libra.conf /etc/libra/devenv/node.conf /etc/libra/devenv/controller.conf /etc/libra

# enable disk quotas
/usr/bin/rhc-init-quota

# secure remounts of special filesystems
#/usr/libexec/li/devenv/remount-secure.sh

%post node
# mount all desired cgroups under a single root
perl -p -i -e 's:/cgroup/[^\s]+;:/cgroup/all;:; /blkio|cpuset|devices/ && ($_ = "#$_")' /etc/cgconfig.conf
/sbin/restorecon /etc/cgconfig.conf || :
# only restart if it's on
chkconfig cgconfig && /sbin/service cgconfig restart >/dev/null 2>&1 || :
/sbin/chkconfig --add libra || :
/sbin/chkconfig --add libra-data || :
/sbin/chkconfig --add libra-cgroups || :
/sbin/chkconfig --add libra-tc || :
/sbin/service mcollective restart > /dev/null 2>&1 || :
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
semanage login -m -s guest_u __default__ || :

%preun node
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

%postun node
if [ "$1" -eq 1 ]; then
    /sbin/service mcollective restart > /dev/null 2>&1 || :
fi
#/usr/sbin/semodule -r libra

%files
%defattr(-,root,root,-)
%doc docs/USAGE.txt
%{_bindir}/rhc-create-app
%{_bindir}/rhc-create-domain
%{_bindir}/rhc-user-info
%{_bindir}/rhc-ctl-app
%{_bindir}/rhc-snapshot
%{_mandir}/man1/rhc-*
%{_mandir}/man5/libra*
%{gemdir}/gems/li-%{version}/
%{gemdir}/cache/li-%{version}.gem
%{gemdir}/doc/li-%{version}
%{gemdir}/specifications/li-%{version}.gemspec
%config(noreplace) %{_sysconfdir}/libra/libra.conf

%files devenv
%defattr(-,root,root,-)
%{_sysconfdir}/libra/devenv/

%files common
%defattr(-,root,root,-)
%{_libexecdir}/mcollective/mcollective/connector/amqp.rb

%files node
%defattr(-,root,root,-)
%{_libexecdir}/mcollective/mcollective/agent/libra.ddl
%{_libexecdir}/mcollective/mcollective/agent/libra.rb
%{_libexecdir}/mcollective/update_yaml.pp
%{ruby_sitelibdir}/facter/libra.rb
%{_sysconfdir}/init.d/libra
%{_sysconfdir}/init.d/libra-data
%{_sysconfdir}/init.d/libra-cgroups
%{_sysconfdir}/init.d/libra-tc
%{_bindir}/rhc-ip-prep.sh
%{_bindir}/trap-user
%{_bindir}/rhc-restorecon
%{_bindir}/rhc-init-quota
%attr(0751,root,root) %{_localstatedir}/lib/libra
%{_libexecdir}/li/cartridges/li-controller-0.1/
%{_datadir}/selinux/packages/libra.pp
%config(noreplace) %{_sysconfdir}/libra/node.conf
%config(noreplace) %{_sysconfdir}/libra/resource_limits.conf
%attr(0750,root,root) %{_sysconfdir}/httpd/conf.d/000000_default.conf
%attr(0640,root,root) %{_sysconfdir}/httpd/conf.d/libra

%files node-tools
%defattr(-,root,root,-)
%{_bindir}/li-accounts
%{_bindir}/li-applications
%{gemdir}/gems/li-node-tools-%{version}
%{gemdir}/cache/li-node-tools-%{version}.gem
%{gemdir}/doc/li-node-tools-%{version}
%{gemdir}/specifications/li-node-tools-%{version}.gemspec

%files server
%defattr(-,root,root,-)
%{_bindir}/rhc-capacity
%{_bindir}/rhc-new-user
%{_bindir}/rhc-get-user-info
%{_bindir}/rhc-cartridge-do
%{_localstatedir}/www/html/libra
%{_localstatedir}/www/html/app
%{_sysconfdir}/httpd/conf.d/rails.conf
%config(noreplace) %{_sysconfdir}/libra/controller.conf

%post server
pushd %{_localstatedir}/www/html/libra > /dev/null
bundle install --deployment
popd > /dev/null
mkdir -p %{_localstatedir}/www/html/libra/log
touch %{_localstatedir}/www/html/libra/log/production.log
chmod 0666 %{_localstatedir}/www/html/libra/log/production.log
touch %{_localstatedir}/www/html/libra/db/production.sqlite3

%files cartridge-php-5.3.2
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/php-5.3.2/

%files cartridge-rack-1.1.0
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/rack-1.1.0/

%files cartridge-wsgi-3.2.1
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/wsgi-3.2.1/

%changelog
* Thu Mar 24 2011 Mike McGrath <mmcgrath@redhat.com> 0.59.1-1
- Fixing site related issues

* Thu Mar 24 2011 Mike McGrath <mmcgrath@redhat.com> 0.59-1
- New release

* Sun Mar 20 2011 Mike McGrath <mmcgrath@redhat.com> 0.58-2
- Added docs

* Sat Mar 19 2011 Mike McGrath <mmcgrath@redhat.com> 0.58-1
- New release
- Disabled secure mount

* Sat Mar 19 2011 Mike McGrath <mmcgrath@redhat.com> 0.56-2
- Added conf.d/libra

* Fri Mar 18 2011 Mike McGrath <mmcgrath@redhat.com> 0.56-1
- Prepping for release

* Fri Mar 18 2011 Mike McGrath <mmcgrath@redhat.com> 0.54-1
- Removing quota bits

* Fri Mar 18 2011 Mike McGrath <mmcgrath@redhat.com> 0.53-1
- New release

* Thu Mar 17 2011 Mike McGrath <mmcgrath@redhat.com> 0.52-1
- New release

* Thu Mar 17 2011 Mike McGrath <mmcgrath@redhat.com> 0.51-1
- New release

* Wed Mar 16 2011 Mike McGrath <mmcgrath@redhat.com> 0.50-1
- New release

* Wed Mar 16 2011 Mike McGrath <mmcgrath@redhat.com> 0.48-1
- New release

* Wed Mar 16 2011 Matt Hicks <mhicks@redhat.com> 0.47-3
- Renaming client.conf to libra.conf

* Wed Mar 16 2011 Mike McGrath <mmcgrath@redhat.com> 0.47-2
- added php-gd and php-xml to the php dep list

* Wed Mar 16 2011 Matt Hicks <mhicks@redhat.com> 0.47-1
- Adding rhc-ip-prep.sh to node files
- Adding site RPM

* Wed Mar 16 2011 Mike McGrath <mmcgrath@redhat.com> 0.46-4
- Added rhc-ip-prep.sh and auto run
- Added requires for php-pdo

* Tue Mar 15 2011 Mike McGrath <mmcgrath@redhat.com> 0.46-3
- Removed rhc-capacity from li tools

* Tue Mar 15 2011 Mike McGrath <mmcgrath@redhat.com> 0.46-2
- Fixed manpage name

* Tue Mar 15 2011 Jim Jagielski <jimjag@redhat.com> 0.46-1
- New version

* Tue Mar 15 2011 Mike McGrath <mmcgrath@redhat.com> 0.45-2
- Added semanage command for guest users

* Mon Mar 14 2011 Mike McGrath <mmcgrath@redhat.com> 0.45-1
- New version

* Mon Mar 14 2011 Mike McGrath <mmcgrath@redhat.com> 0.44-1
- Upstream released new version

* Fri Mar 11 2011 Mike McGrath <mmcgrath@redhat.com> 0.42-2
- Added restorecon to libra and mcollective

* Fri Mar 11 2011 Mike McGrath <mmcgrath@redhat.com> 0.42-1
- New release

* Thu Mar 10 2011 Matt Hicks <mhicks@redhat.com> 0.41-6
- Fixed file path

* Thu Mar 10 2011 Matt Hicks <mhicks@redhat.com> 0.41-5
- Moved vhost file definition to the node section

* Thu Mar 10 2011 Matt Hicks <mhicks@redhat.com> 0.41-4
- Added files definition for the default vhost file

* Thu Mar 10 2011 Matt Hicks <mhicks@redhat.com> 0.41-3
- Removing parseconfig build dep

* Thu Mar 10 2011 Matt Hicks <mhicks@redhat.com> 0.41-2
- Fixing build deps

* Thu Mar 10 2011 Mike McGrath <mmcgrath@redhat.com> 0.41-1
- New version

* Thu Mar 10 2011 Mike McGrath <mmcgrath@redhat.com> 0.40-1
- New version

* Tue Mar 08 2011 Mike McGrath <mmcgrath@redhat.com> 0.39-1
- New version

* Tue Mar 08 2011 Mike McGrath <mmcgrath@redhat.com> 0.38-3
- Added devenv (auto setup)

* Tue Mar 08 2011 Mike McGrath <mmcgrath@redhat.com> 0.38-2
- Added php files

* Sun Mar 07 2011 Mike McGrath <mmcgrath@redhat.com> 0.38-1
- New release

* Sun Mar 06 2011 Mike McGrath <mmcgrath@redhat.com> 0.37-1
- New upstream release

* Fri Mar 04 2011 Mike McGrath <mmcgrath@redhat.com> 0.36-1
- New upstream version

* Fri Mar 04 2011 Mike McGrath <mmcgrath@redhat.com> 0.34-2
- Added git dep on li-node

* Thu Mar 03 2011 Mike McGrath <mmcgrath@redhat.com> 0.34-1
- New upstream version

* Wed Mar 02 2011 Mike McGrath <mmcgrath@redhat.com> 0.33-1
- New upstream version

* Mon Feb 28 2011 Mike McGrath <mmcgrath@redhat.com> 0.32-1
- New upstream version

* Fri Feb 25 2011 Mike McGrath <mmcgrath@redhat.com> 0.31-1
- Release for demo

* Thu Feb 24 2011 Mike McGrath <mmcgrath@redhat.com> 0.30-1
- Prepping for a new release

* Tue Feb 22 2011 Mike McGrath <mmcgrath@redhat.com> 0.29-1
- Upstream released new version
- Added wsgi

* Mon Feb 21 2011 Mike McGrath <mmcgrath@redhat.com> 0.27-1
- Added restorecon bits
- Upstream released new version
- Added new deps and yaml update

* Fri Feb 18 2011 Mike McGrath <mmcgrath@redhat.com> 0.25-1
- New version from upstream

* Tue Feb 15 2011 Mike McGrath <mmcgrath@redhat.com> 0.22-1
- New upstream

* Mon Feb 14 2011 Mike McGrath <mmcgrath@redhat.com> 0.20-1
- New version
- Happy valentines day <3

* Fri Feb 11 2011 Mike McGrath <mmcgrath@redhat.com> 0.19-1
- New version

* Thu Feb 10 2011 Mike McGrath <mmcgrath@redhat.com> 0.18-1
- Upstream released new version

* Thu Feb 10 2011 Matt Hicks <mhicks@redhat.com> 0.17-2
- General cleanup and moving li-capacity to rhc-capacity

* Tue Feb 08 2011 Mike McGrath <mmcgrath@redhat.com> 0.17-1
- Upstream released new version

* Mon Feb 07 2011 Mike McGrath <mmcgrath@redhat.com> 0.16-2
- Upstream released new version

* Thu Feb 03 2011 Mike McGrath <mmcgrath@redhat.com> 0.15-2
- Removed mcollective build requires

* Thu Jan 26 2011 Mike McGrath <mmcgrath@redhat.com> 0.15-1
- Upstream released new version

* Wed Jan 26 2011 Mike McGrath <mmcgrath@redhat.com> 0.14-1
- Upstream released new version

* Tue Jan 25 2011 Mike McGrath <mmcgrath@redhat.com> 0.13-1
- upstream released new version

* Mon Jan 24 2011 Mike McGrath <mmcgrath@redhat.com> 0.12-1
- Upstream released new version

* Mon Jan 24 2011  Matt Hicks <mhicks@redhat.com> 0.11-2
- Added qpid messaging support for mcollective

* Thu Jan 20 2011 Mike McGrath <mmcgrath@redhat.com> 0.11-1
- Upstream released new version

* Wed Jan 19 2011 Mike McGrath <mmcgrath@redhat.com> 0.10-1
- Upstream released new version

* Tue Jan 18 2011 Matt Hicks <mhicks@redhat.com> - 0.09-1
- Added rack cartridge
- Upstream released new version

* Tue Jan 18 2011 Mike McGrath <mmcgrath@redhat.com> - 0.08-1
- Added li-capacity bin
- Upstream released new version

* Mon Jan 17 2011 Mike McGrath <mmcgrath@redhat.com> - 0.07-1
- Upstream released new version
- Added node configs

* Fri Jan 14 2011 Mike McGrath <mmcgrath@redhat.com> - 0.06-1
- Upstream released new version

* Tue Jan 11 2011 Mike McGrath <mmcgrath@redhat.com> - 0.04-1
- Added new binaries
- new upstream release
- Added new ruby deps

* Thu Jan 06 2011 Mike McGrath <mmcgrath@redhat.com> - 0.03-1
- Added li-server bits

* Tue Jan 04 2011 Mike McGrath <mmcgrath@redhat.com> - 0.02-2
- Fixed cartridge

* Tue Jan 04 2011 Mike McGrath <mmcgrath@redhat.com> - 0.01-1
- initial packaging
