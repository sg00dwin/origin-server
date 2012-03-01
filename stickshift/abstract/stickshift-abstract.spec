%define cartdir %{_libexecdir}/li/cartridges

Summary:   StickShift common cartridge components
Name:      stickshift-abstract
Version:   0.5.1
Release:   1%{?dist}
Group:     Network/Daemons
License:   ASL 2.0
URL:       http://openshift.redhat.com
Source0:   stickshift-abstract-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildArch: noarch

%description
This contains the common function used while building cartridges.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartdir}
mkdir -p %{buildroot}%{_sysconfdir}/libra
mv conf/node.conf %{buildroot}%{_sysconfdir}/libra/
mv conf/node_data.conf %{buildroot}%{_sysconfdir}/libra/
cp -rv abstract %{buildroot}%{cartdir}/
cp -rv abstract-httpd %{buildroot}%{cartdir}/
rm -rf %{buildroot}%{cartdir}/conf

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{cartdir}
%defattr(0640,apache,apache,0750)
%config(noreplace) %{_sysconfdir}/libra/node.conf
%config(noreplace) %{_sysconfdir}/libra/node_data.conf
%dir %attr(0755,root,root) %{_libexecdir}/li/cartridges/abstract-httpd/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract-httpd/info/hooks/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract-httpd/info/bin/
%dir %attr(0755,root,root) %{_libexecdir}/li/cartridges/abstract/
%attr(0750,-,-) %{_libexecdir}/li/cartridges/abstract/info/hooks/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract/info/bin/
%attr(0755,-,-) %{_libexecdir}/li/cartridges/abstract/info/lib/

%post

%changelog
