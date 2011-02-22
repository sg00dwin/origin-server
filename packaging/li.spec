%{!?ruby_sitelibdir: %global ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

Name: li
Version: 0.28
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
Requires: rubygem-parseconfig
Requires: rubygem-json
#BuildRequires: rubygem-cucumber
#BuildRequires: mcollective
#BuildRequires: mcollective-client
#BuildRequires: mcollective-common

%description
Provides Li client libraries

%package devel
Summary: Dependencies for Libra development
Group: Development/Libraries
Requires: rubygem-rake
Requires: rubygem-cucumber
Requires: rubygem-rspec
Requires: rubygem-aws
Requires: rubygem-json
Requires: mcollective-client
Requires: mcollective-common
Requires: ruby-qpid
BuildArch: noarch

%description devel
Provides all the development dependencies to be able to run the libra tests

%package node
Summary: Multi-tenant cloud management system node tools
Group: Network/Daemons
Requires: mcollective
Requires: ruby-qpid
Requires: rubygem-parseconfig
Requires: libcgroup
Requires(post): /usr/sbin/semodule
Requires(postun): /usr/sbin/semodule
BuildArch: noarch

%description node
Turns current host into a Li managed node

%package server
Summary: Li server components
Group: Network/Daemons
Requires: mcollective-client
Requires: ruby-qpid
BuildArch: noarch
Requires: ruby-json
Requires: rubygem-aws
Requires: rubygem-parseconfig

%description server
This contains the server 'controlling' components of Li.  This can be on the
same host as a node.

Note: to use this you'll need qpid installed somewhere.  It doesn't have
to be the same host as the server.  It is the 'qpid-cpp-server' package.

%package cartridge-php-5.3.2
Summary: Provides php-5.3.2 support
Group: Development/Languages
Requires: li-node
Requires: php = 5.3.2
Requires: rubygem-builder
BuildArch: noarch

%description cartridge-php-5.3.2
Provides php support to li

%package cartridge-rack-1.1.0
Summary: Provides ruby rack support running on Phusion Passenger
Group: Development/Languages
Requires: li-node
Requires: ruby
Requires: rubygems
Requires: rubygem-rack = 1:1.1.0
Requires: rubygem-passenger = 1:3.0.2
Requires: rubygem-passenger-native
Requires: rubygem-passenger-native-libs
Requires: mod_passenger
BuildArch: noarch

%description cartridge-rack-1.1.0
Provides rack support to li

%prep
%setup -q


%build
rake test_client
rake test_node
rake test_server


%install
rm -rf $RPM_BUILD_ROOT
rake DESTDIR="$RPM_BUILD_ROOT" install
mkdir -p .%{gemdir}
gem install --install-dir $RPM_BUILD_ROOT/%{gemdir} --local -V --force --rdoc \
     backend/controller/pkg/li-controller-%{version}.gem


%clean
rm -rf $RPM_BUILD_ROOT


%post node
/sbin/chkconfig --add libra || :
/sbin/chkconfig --add libra-data || :
/sbin/chkconfig --add libra-cgroups || :
/sbin/service mcollective restart > /dev/null 2>&1 || :
/usr/sbin/semodule -i %_datadir/selinux/packages/libra.pp
/sbin/restorecon /etc/init.d/libra || :
/usr/bin/rhc-restorecon || :
/sbin/service libra-cgroups start > /dev/null 2>&1 || :
/sbin/service libra-data start > /dev/null 2>&1 || :


%preun node
if [ "$1" -eq "0" ]; then
    /sbin/service libra-cgroups stop > /dev/null 2>&1 || :
    /sbin/chkconfig --del libra-cgroups || :
    /sbin/chkconfig --del libra-data || :
    /sbin/chkconfig --del libra || :
    /usr/sbin/semodule -r libra
fi

%postun node
if [ "$1" -eq 1 ]; then
    /sbin/service mcollective restart > /dev/null 2>&1 || :
fi
#/usr/sbin/semodule -r libra

%files
%defattr(-,root,root,-)
%{_bindir}/rhc-capacity
%{_bindir}/rhc-create-app
%{_bindir}/rhc-create-user
%{_bindir}/rhc-user-info
%{_bindir}/rhc-ctl-app
%{_mandir}/man1/rhc-*
%{_mandir}/man5/libra*
%config(noreplace) %{_sysconfdir}/libra/client.conf


%files node
%defattr(-,root,root,-)
%{_libexecdir}/mcollective/mcollective/agent/libra.rb
%{_libexecdir}/mcollective/mcollective/connector/amqp.rb
%{ruby_sitelibdir}/facter/libra.rb
%{_sysconfdir}/init.d/libra
%{_sysconfdir}/init.d/libra-data
%{_sysconfdir}/init.d/libra-cgroups
%{_bindir}/trap-user
%{_bindir}/rhc-restorecon
%attr(0751,root,root) %{_localstatedir}/lib/libra
%{_libexecdir}/li/cartridges/li-controller-0.1/
%{_datadir}/selinux/packages/libra.pp
%config(noreplace) %{_sysconfdir}/libra/node.conf


%files server
%defattr(-,root,root,-)
%{_libexecdir}/mcollective/mcollective/agent/libra.ddl
%{_libexecdir}/mcollective/update_yaml.pp
%{_bindir}/rhc-capacity
%{_bindir}/rhc-new-user
%{_bindir}/mc-rhc-cartridge-do
%config(noreplace) %{_sysconfdir}/libra/controller.conf
%{gemdir}/gems/li-controller-%{version}
%{gemdir}/bin/mc-rhc-cartridge-do
%{gemdir}/bin/rhc-new-user
%{gemdir}/bin/rhc-capacity
%{gemdir}/cache/li-controller-%{version}.gem
%{gemdir}/doc/li-controller-%{version}
%{gemdir}/specifications/li-controller-%{version}.gemspec


%files cartridge-php-5.3.2
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/php-5.3.2/

%files cartridge-rack-1.1.0
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/rack-1.1.0/

%changelog
* Tue Feb 22 2011 Mike McGrath <mmcgrath@redhat.com> 0.28-1
- Upstream released new version

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
