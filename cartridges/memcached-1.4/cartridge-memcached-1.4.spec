%define cartridgedir %{_libexecdir}/stickshift/cartridges/embedded/memcached-1.4

Name: cartridge-memcached-1.4
Version: 0.2.4
Release: 1%{?dist}
Summary: Embedded memcached support for express

Group: Network/Daemons
License: ASL 2.0
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Obsoletes: rhc-cartridge-memcached-1.4

Requires: rubygem(stickshift-node)
Requires: stickshift-abstract
Requires: memcached
Requires: libmemcached
Requires: php-pecl-memcache
Requires: php-pecl-memcached
Requires: perl-Cache-Memcached
Requires: python-memcached.noarch
#
# TO DO:
# Requires: xmemcached.noarch - need pkg http://code.google.com/p/xmemcached/
# Requires: rubygem-memcached - need rubygem for memcached gem


%description
Provides rhc memcached cartridge support

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/stickshift/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/stickshift/cartridges/%{name}
cp -r info %{buildroot}%{cartridgedir}/
cp LICENSE %{buildroot}%{cartridgedir}/
cp COPYRIGHT %{buildroot}%{cartridgedir}/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/build/
%config(noreplace) %{cartridgedir}/info/configuration/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%attr(0755,-,-) %{cartridgedir}/info/lib/
%{_sysconfdir}/stickshift/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control
%{cartridgedir}/info/manifest.yml
%doc %{cartridgedir}/COPYRIGHT
%doc %{cartridgedir}/LICENSE

%changelog
* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.2.4-1
- Test commit (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.2.3-1
- test commits (mmcgrath@redhat.com)
- Return in a way that broker can manage. (rmillner@redhat.com)

* Mon Apr 02 2012 Krishna Raman <kraman@gmail.com> 0.2.2-1
- 

* Fri Mar 30 2012 Krishna Raman <kraman@gmail.com> 0.2.1-1
- Renaming for open-source release

* Thu Jan 12 2012 Ram Ranganathan <ramr@redhat.com> 0.1-1
- Initial packaging
