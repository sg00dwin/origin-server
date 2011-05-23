Name: rhc-common
Version: 0.70.2
Release: 1%{?dist}
Group: Network/Daemons
License: GPLv2
URL: https://engineering.redhat.com/trac/Libra
Source0: rhc-common-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch
Summary: Common dependencies of the libra server and node
Requires: mcollective-client
Requires: qpid-cpp-client
Requires: qpid-cpp-client-ssl
Requires: ruby-qmf

%description
Provides the common dependencies for the OpenShift server and nodes

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_libexecdir}/mcollective/mcollective/connector
cp mcollective/connector/amqp.rb %{buildroot}%{_libexecdir}/mcollective/mcollective/connector
touch %{buildroot}%{_sysconfdir}/mcollective/client.cfg

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%ghost %{_sysconfdir}/mcollective/client.cfg
%attr(-,-,libra_user) %{_sysconfdir}/mcollective/client.cfg
%{_libexecdir}/mcollective/mcollective/connector/amqp.rb
