%{!?ruby_sitelibdir: %global ruby_sitelibdir %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')}

Name: li
Version: 0.02
Release: 1%{?dist}
Summary: Multi-tenant cloud management system client tools

Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: li-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires: rake

%description
Provides Li client libraries

%package node
Summary: Multi-tenant cloud management system node tools
Group: Network/Daemons
Requires: mcollective

%description node
Turns current host into a Li managed node

%package cartridge-php-4.3.2
Summary: Provides php-4.3.2 support
Group: Development/Languages
Requires: li-node
Requires: php = 4.3.2

%description cartridge-php-4.3.2
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

%files cartridge-php-4.3.2
%defattr(-,root,root,-)
%{_libexecdir}/li/cartridges/php-5.3.2/

%changelog
* Tue Jan 04 2011 Mike McGrath <mmcgrath@redhat.com> - 0.01-1
- initial packaging
