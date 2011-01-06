%{!?ruby_sitelibdir: %global ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}

Name: li
Version: 0.03
Release: 1%{?dist}
Summary: Multi-tenant cloud management system client tools

Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: li-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

BuildRequires: rubygem-rake

%description
Provides Li client libraries

%package node
Summary: Multi-tenant cloud management system node tools
Group: Network/Daemons
Requires: mcollective
BuildArch: noarch

%description node
Turns current host into a Li managed node

%package server
Summary: Li server components
Group: Network/Daemons
Requires: mcollective-client
BuildArch: noarch

%description server
This contains the server 'controlling' components of Li.  This can be on the
same host as a node.

Note: to use this you'll need activemq installed somewhere.  It doesn't have
to be the same host as the server.

%package cartridge-php-5.3.2
Summary: Provides php-5.3.2 support
Group: Development/Languages
Requires: li-node
Requires: php = 5.3.2
BuildArch: noarch

%description cartridge-php-5.3.2
Provides php support to li

%prep
%setup -q


%build
rake test_client
rake test_node


%install
rm -rf $RPM_BUILD_ROOT
rake DESTDIR="$RPM_BUILD_ROOT" install

%clean
rm -rf $RPM_BUILD_ROOT

%post node
/sbin/chkconfig --add libra || :
/sbin/service mcollective restart > /dev/null 2>&1 || :

%preun node
if [ "$1" -ge 1 ]; then
    /sbin/chkconfig --del libra || :
fi
%postun node
if [ "$1" -ge 1 ]; then
    /sbin/service mcollective restart > /dev/null 2>&1 || :
fi

%files
%defattr(-,root,root,-)
%{_bindir}/libra_*

%files node
%defattr(-,root,root,-)
%{_libexecdir}/mcollective/mcollective/agent/libra.rb
%{ruby_sitelibdir}/facter/libra.rb
%{_sysconfdir}/init.d/libra
%{_bindir}/trap-user
%{_localstatedir}/lib/libra
%{_libexecdir}/li/cartridges/li-controller-0.1/

%files server
%defattr(-,root,root,-)
%{_libexecdir}/mcollective/mcollective/agent/libra.ddl

%files cartridge-php-5.3.2
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/php-5.3.2/

%changelog
* Thu Jan 06 2011 Mike McGrath <mmcgrath@redhat.com> - 0.03-1
- Added li-server bits

* Tue Jan 04 2011 Mike McGrath <mmcgrath@redhat.com> - 0.02-2
- Fixed cartridge

* Tue Jan 04 2011 Mike McGrath <mmcgrath@redhat.com> - 0.01-1
- initial packaging
