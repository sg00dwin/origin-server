%{!?ruby_sitelibdir: %global ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

Name: rhc
Version: 0.67.9
Release: 1%{?dist}
Summary: Multi-tenant cloud management system client tools

Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-%{version}.tar.gz
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
Requires: rhc
Requires: rhc-common
Requires: rhc-node
Requires: rhc-node-tools
Requires: rhc-server
Requires: rhc-cartridge-php-5.3.2
Requires: rhc-cartridge-wsgi-3.2.1
Requires: rhc-cartridge-rack-1.1.0
Requires: qpid-cpp-server
Requires: qpid-cpp-server-ssl
Requires: puppet
Requires: rubygem-cucumber
Requires: rubygem-mocha
Requires: rubygem-rspec
Requires: rubygem-nokogiri
BuildArch: noarch

%description devenv
Provides all the development dependencies to be able to run the libra tests

%package common
Summary: Common dependencies of the libra server and node
Group: Network/Daemons
Requires: mcollective-client
Requires: qpid-cpp-client
Requires: qpid-cpp-client-ssl
Requires: ruby-qmf
BuildArch: noarch

%description common
Provides the common dependencies for the libra server and nodes

%package node
Summary: Multi-tenant cloud management system node tools
Group: Network/Daemons
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
BuildArch: noarch

%description node
Turns current host into a Li managed node

%package node-tools
Summary: Utilities to help monitor and manage a Li node
Group: Network/Daemons
BuildRequires: rubygem-nokogiri
BuildRequires: rubygem-json
Requires: rubygem-nokogiri
Requires: rubygem-json
BuildArch: noarch

%description node-tools
Status and control tools for Libra Nodes

%package server
Summary: Li server components
Group: Network/Daemons
Requires: rhc-common
BuildArch: noarch
Requires: httpd
Requires: ruby
Requires: rubygems
Requires: rubygem-abstract
Requires: rubygem-aws
Requires: rubygem-erubis
Requires: rubygem-mime-types
Requires: rubygem-rack = 1:1.1.0
Requires: rubygem-passenger
Requires: rubygem-passenger-native
Requires: rubygem-passenger-native-libs
Requires: mod_passenger
Requires: rubygem-bundler

%description server
This contains the server 'controlling' components of Li.  This can be on the
same host as a node.  It also contains the rails site and public APIs.

Note: to use this you'll need qpid installed somewhere.  It doesn't have
to be the same host as the server.  It is the 'qpid-cpp-server' package.

%package cartridge-php-5.3.2
Summary: Provides php-5.3.2 support
Group: Development/Languages
Requires: rhc-node
Requires: php = 5.3.2
Requires: mod_bw
Requires: rubygem-builder
Requires: php-pdo
Requires: php-gd
Requires: php-xml
Requires: php-mysql
Requires: php-pgsql
BuildArch: noarch

%description cartridge-php-5.3.2
Provides php support to rhc

%package cartridge-rack-1.1.0
Summary: Provides ruby rack support running on Phusion Passenger
Group: Development/Languages
Requires: rhc-node
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
Requires: ruby-nokogiri
BuildArch: noarch

%description cartridge-rack-1.1.0
Provides rack support to rhc

%package cartridge-wsgi-3.2.1
Summary: Provides python-wsgi-3.2.1 support
Group: Development/Languages
Requires: rhc-node
Requires: httpd
Requires: mod_bw
Requires: python
Requires: mod_wsgi = 3.2
Requires: MySQL-python
Requires: python-psycopg2
BuildArch: noarch

%description cartridge-wsgi-3.2.1
Provides wsgi support to rhc

%package cartridge-jbossas-7.0.0
Summary: Provides java-jbossas-7.0.0 support
Group: Development/Languages
Requires: rhc-node
BuildArch: noarch

%description cartridge-jbossas-7.0.0
Provides jbossas support to rhc

%prep
%setup -q


%build
rake install:test:all

%install
rm -rf $RPM_BUILD_ROOT
rake DESTDIR="$RPM_BUILD_ROOT" install:all
ln -s %{_localstatedir}/www/libra/public $RPM_BUILD_ROOT/%{_localstatedir}/www/html/app

mkdir $RPM_BUILD_ROOT/etc/libra/devenv/
cp -adv misc/devenv/* $RPM_BUILD_ROOT/etc/libra/devenv/

mkdir -p .%{gemdir}
gem install --install-dir $RPM_BUILD_ROOT/%{gemdir} --bindir $RPM_BUILD_ROOT/%{_bindir} --local -V --force --rdoc \
     client/pkg/rhc-%{version}.gem
gem install --install-dir $RPM_BUILD_ROOT/%{gemdir} --bindir $RPM_BUILD_ROOT/%{_bindir} --local -V --force --rdoc \
     node/tools/pkg/li-node-tools-%{version}.gem

%clean
rm -rf $RPM_BUILD_ROOT

%pre server
/usr/sbin/groupadd -r libra_user 2>&1 || :
/usr/sbin/useradd libra_passenger -g libra_user -d /var/lib/passenger -r -s /sbin/nologin 2>&1 > /dev/null || :

%post devenv

# ntp is not needed in para-virtualized systems
# the host maintains the clock
#service ntpd start
#chkconfig ntpd on

# qpid - configuring SSL
/bin/cp -rf /etc/libra/devenv/qpid/etc/* /etc/
/sbin/restorecon -R /etc/qpid/pki
service qpidd restart
chkconfig qpidd on

# mcollective
/bin/cp -f /etc/libra/devenv/client.cfg /etc/libra/devenv/server.cfg /etc/mcollective
/bin/touch /tmp/mcollective-client.log
/bin/chmod 0666 /tmp/mcollective-client.log
service mcollective start
chkconfig mcollective on

# cggroups
chkconfig cgconfig on
service cgconfig start
chkconfig cgred on
service cgred start
service libra-cgroups start
service libra-tc start

# iptables
/bin/cp -f /etc/libra/devenv/iptables /etc/sysconfig/iptables
/etc/init.d/iptables restart

# rails setup
ln -s /var/www/libra/public/* /var/www/html/.
/bin/touch %{_localstatedir}/www/libra/log/development.log
/bin/chmod 0666 %{_localstatedir}/www/libra/log/development.log
/bin/mkdir -p /var/www/libra/httpd/logs
/bin/mkdir -p /var/www/libra/httpd/run
/bin/ln -s /usr/lib64/httpd/modules/ /var/www/libra/httpd/modules
/bin/cp -f /etc/libra/devenv/httpd/000000_default.conf /etc/httpd/conf.d
/bin/cp -f /etc/libra/devenv/httpd/broker.conf /var/www/libra/httpd
/bin/cp -f /etc/libra/devenv/httpd/httpd.conf /var/www/libra/httpd
/bin/cp -f /etc/libra/devenv/libra-site /etc/init.d
/bin/cp -f /etc/libra/devenv/robots.txt /var/www/libra/public
/etc/init.d/libra-site restart
chkconfig libra-site on

# httpd
/etc/init.d/httpd restart
chkconfig httpd on

# Allow httpd to relay
/usr/sbin/setsebool -P httpd_can_network_relay=on || :

# Increase kernel semaphores to accomodate many httpds
echo "kernel.sem = 250	32000	32	4096" >> /etc/sysctl.conf
sysctl kernel.sem="250	32000	32	4096"

# Setup facts
/usr/bin/puppet /usr/libexec/mcollective/update_yaml.pp
crontab -u root /etc/libra/devenv/crontab

# Libra
/bin/cp -f /etc/libra/devenv/node.conf /etc/libra/devenv/controller.conf /etc/libra
/bin/cp -f /etc/libra/devenv/express.conf /etc/openshift

# Debugging utilities
/bin/cp -f /etc/libra/devenv/li-log-util /usr/bin/li-log-util

# enable disk quotas
/usr/bin/rhc-init-quota

# secure remounts of special filesystems
#/usr/libexec/li/devenv/remount-secure.sh

# Increase max SSH connections and tries to 40
perl -p -i -e "s/^#MaxSessions .*$/MaxSessions 40/" /etc/ssh/sshd_config
perl -p -i -e "s/^#MaxStartups .*$/MaxStartups 40/" /etc/ssh/sshd_config

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
%doc misc/docs/USAGE.txt
%{_bindir}/rhc-create-app
%{_bindir}/rhc-create-domain
%{_bindir}/rhc-user-info
%{_bindir}/rhc-ctl-app
%{_bindir}/rhc-snapshot
%{_mandir}/man1/rhc-*
%{_mandir}/man5/express*
%{gemdir}/gems/rhc-%{version}/
%{gemdir}/cache/rhc-%{version}.gem
%{gemdir}/doc/rhc-%{version}
%{gemdir}/specifications/rhc-%{version}.gemspec
%config(noreplace) %{_sysconfdir}/openshift/express.conf

%files devenv
%defattr(-,root,root,-)
%{_sysconfdir}/libra/devenv/

%files common
%defattr(-,root,root,-)
%{_libexecdir}/mcollective/mcollective/connector/amqp.rb

%files node
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

%files node-tools
%defattr(-,root,root,-)
%attr(0750,-,-) %{_bindir}/rhc-node-accounts
%attr(0750,-,-) %{_bindir}/rhc-node-apps
%attr(0750,-,-) %{_bindir}/rhc-node-status
%{gemdir}/gems/li-node-tools-%{version}
%{gemdir}/cache/li-node-tools-%{version}.gem
%{gemdir}/doc/li-node-tools-%{version}
%{gemdir}/specifications/li-node-tools-%{version}.gemspec

%files server
%defattr(0640,root,libra_user,0750)
%attr(0750,-,-) %{_bindir}/rhc-capacity
%attr(0750,-,-) %{_bindir}/rhc-new-user
%attr(0750,-,-) %{_bindir}/rhc-get-user-info
%attr(0750,-,-) %{_bindir}/rhc-cartridge-do
%attr(-,root,libra_user) %{_localstatedir}/www/libra
%attr(-,root,libra_user) %{_localstatedir}/www/html/app
%attr(0640,root,libra_user) %config(noreplace) %{_sysconfdir}/libra/controller.conf

%post server

# Change group for mcollective client.cfg
/bin/chgrp libra_user /etc/mcollective/client.cfg

# Install any Rails dependencies
pushd %{_localstatedir}/www/libra > /dev/null
bundle install --deployment
popd > /dev/null
mkdir -p %{_localstatedir}/www/libra/log
touch %{_localstatedir}/www/libra/log/production.log
chmod 0666 %{_localstatedir}/www/libra/log/production.log

/etc/init.d/httpd restart

%files cartridge-php-5.3.2
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/php-5.3.2/

%files cartridge-rack-1.1.0
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/rack-1.1.0/

%files cartridge-wsgi-3.2.1
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/wsgi-3.2.1/

%files cartridge-jbossas-7.0.0
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/jbossas-7.0.0/

%changelog
* Tue Apr 26 2011 Mike McGrath <mmcgrath@redhat.com> 0.67.9-1
- Fix from DAN for legal changes

* Tue Apr 26 2011 Matt Hicks <mhicks@redhat.com> 0.67.8-1
- Legal terms changes

* Tue Apr 26 2011 Matt Hicks <mhicks@redhat.com> 0.67.7-1
- Site workflow improvements

* Tue Apr 26 2011 Matt Hicks <mhicks@redhat.com> 0.67.6-1
- DNS error handling fix

* Tue Apr 26 2011 Matt Hicks <mhicks@redhat.com> 0.67.5-1
- Client message tweak
- Site terms flow updates
- Minor bug fixes

* Fri Apr 22 2011 Matt Hicks <mhicks@redhat.com> 0.67.4-1
- Site improvements

* Fri Apr 22 2011 Matt Hicks <mhicks@redhat.com> 0.67.3-1
- Site improvements

* Fri Apr 22 2011 Matt Hicks <mhicks@redhat.com> 0.67.2-1
- Major site improvements

* Fri Apr 22 2011 Matt Hicks <mhicks@redhat.com> 0.67.1-1
- Major site improvements

* Thu Apr 21 2011 Matt Hicks <mhicks@redhat.com> 0.66.5-1
- Improved broker httpd.conf file
- Increase mcollective command timeout

* Wed Apr 20 2011 Matt Hicks <mhicks@redhat.com> 0.66.4-1
- Terms flows and getting started pages

* Wed Apr 20 2011 Mike McGrath <mmcgrath@redhat.com> 0.66.3-2
- Fixed gem names

* Wed Apr 20 2011 Mike McGrath <mmcgrath@redhat.com> 0.66.3-1
- More updates for release

* Wed Apr 20 2011 Mike McGrath <mmcgrath@redhat.com> 0.66.2-1
- Rebuilding for latest version

* Wed Apr 20 2011 Mike McGrath <mmcgrath@redhat.com> 0.66.1-1
- Renaming to rhc

* Mon Apr 20 2011 Matt Hicks <mhicks@redhat.com> 0.65.6-1
- Increasing discovery timeout for mcollective clients
- Test frameworking fixes and improvements

* Mon Apr 19 2011 Matt Hicks <mhicks@redhat.com> 0.65.5-1
- Removing passenger conservative spawning

* Mon Apr 19 2011 Matt Hicks <mhicks@redhat.com> 0.65.4-1
- More site flows

* Mon Apr 19 2011 Matt Hicks <mhicks@redhat.com> 0.65.3-1
- Client error handling improvements and timeout increases
- Test framework improvements on HTTP connections

* Mon Apr 18 2011 Matt Hicks <mhicks@redhat.com> 0.65.2-1
- Switching DYN usernames back for devenv

* Mon Apr 18 2011 Mike McGrath <mmcgrath@redhat.com> 0.65.1-2
- Prepping for a release (ssl fixes, DYN, passenger)

* Sun Apr 17 2011 Mike McGrath <mmcgrath@redhat.com> 0.64.2-1
- Fixed issue with configure and long df lines
- Removing personal data from the nodes

* Fri Apr 15 2011 Matt Hicks <mhicks@redhat.com> 0.64.1-1
- Prepping new release

* Fri Apr 15 2011 Mike McGrath <mmcgrath@redhat.com> 0.63.5-2
- Added postgres deps

* Thu Apr 14 2011 Matt Hicks <mhicks@redhat.com> 0.63.5-1
- SELinux policy fix and qpid over SSL

* Thu Apr 14 2011 Mike McGrath <mmcgrath@redhat.com> 0.63.4-1
- New site release

* Tue Apr 10 2011 Mike McGrath <mmcgrath@redhat.com> 0.63.1-2
- Added jbossas-7.0.0

* Tue Apr 10 2011 Mike McGrath <mmcgrath@redhat.com> 0.63.1-1
- New week, new version

* Sun Apr 10 2011 Mike McGrath <mmcgrath@redhat.com> 0.62.14-1
- Update to make rack operational

* Fri Apr 10 2011 Matt Hicks <mhicks@redhat.com> 0.62.13-1
- Switching Passenger node to conversative spawning to avoid SELinux error

* Fri Apr 10 2011 Matt Hicks <mhicks@redhat.com> 0.62.12-1
- Switching Passenger to conversative spawning to avoid SELinux error

* Fri Apr 08 2011 Mike McGrath <mmcgrath@redhat.com> 0.62.11-1
- New release

* Tue Apr 07 2011 Mike McGrath <mmcgrath@redhat.com> 0.62.9-2
- creating /etc/openshift

* Thu Apr 07 2011 Mike McGrath <mmcgrath@redhat.com> 0.62.9-1
- Fixing openshift path in devenv

* Thu Apr 07 2011 Matt Hicks <mhicks@redhat.com> 0.62.8-1
- Site functioning with streamline
- Additional fixes

* Thu Apr 07 2011 Matt Hicks <mhicks@redhat.com> 0.62.7-1
- Lots of site updates
- Additional fixes

* Tue Apr 05 2011 Mike McGrath <mmcgrath@redhat.com> 0.62.6-4
- Fixing /var/lib/libra permissions
- Allowing execute to trap-user

* Tue Apr 05 2011 Mike McGrath <mmcgrath@redhat.com> 0.62.6-2
- Additional fixes

* Tue Apr 05 2011 Matt Hicks <mhicks@redhat.com> 0.62.5-4
- server.rb typo fix

* Tue Apr 05 2011 Matt Hicks <mhicks@redhat.com> 0.62.4-4
- Moving user / group to %pre

* Tue Apr 05 2011 Matt Hicks <mhicks@redhat.com> 0.62.3-3
- Removed server rubygem-haml dep

* Tue Apr 05 2011 Matt Hicks <mhicks@redhat.com> 0.62.2-2
- More fixes (permissions and script tweaks)
- Added server rubygem-haml dep

* Tue Apr 05 2011 Mike McGrath <mmcgrath@redhat.com> 0.62.1-1
- Fixes from last nights breakage.

* Mon Apr 04 2011 Mike McGrath <mmcgrath@redhat.com> 0.62-1
- New nightly release for QE

* Sun Apr 03 2011 Mike McGrath <mmcgrath@redhat.com> 0.61.3-2
- Securing bineries and other libra specific bins

* Sat Apr 02 2011 Mike McGrath <mmcgrath@redhat.com> 0.61.3-1
- Fixing dep loading issue from Matt

* Fri Apr 01 2011 Mike McGrath <mmcgrath@redhat.com> 0.61.2-1
- Additional changes to site

* Fri Apr 01 2011 Mike McGrath <mmcgrath@redhat.com> 0.61.1-1
- Fixes for cartridge stopping and route

* Fri Mar 31 2011 Mike McGrath <mmcgrath@redhat.com> 0.62-2
- Release bump

* Thu Mar 30 2011 Mike McGrath <mmcgrath@redhat.com> 0.61-1
- Prepping for tomorrows release

* Mon Mar 28 2011 Mike McGrath <mmcgrath@redhat.com> 0.60.4-1
- Additional site and streamline fixes

* Thu Mar 24 2011 Mike McGrath <mmcgrath@redhat.com> 0.60.3-1
- Additional site related fixes

* Thu Mar 24 2011 Mike McGrath <mmcgrath@redhat.com> 0.60-1
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
