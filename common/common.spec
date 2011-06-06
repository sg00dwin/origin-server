Summary:   Common dependencies of the libra server and node
Name:      rhc-common
Version:   0.72.2
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-common-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  mcollective-client
Requires:  qpid-cpp-client
Requires:  qpid-cpp-client-ssl
Requires:  ruby-qmf

BuildArch: noarch

%description
Provides the common dependencies for the OpenShift server and nodes

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_sysconfdir}/mcollective
mkdir -p %{buildroot}%{_libexecdir}/mcollective/mcollective/connector
cp mcollective/connector/amqp.rb %{buildroot}%{_libexecdir}/mcollective/mcollective/connector
touch %{buildroot}%{_sysconfdir}/mcollective/client.cfg

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%ghost %attr(-,-,libra_user) %{_sysconfdir}/mcollective/client.cfg
%{_libexecdir}/mcollective/mcollective/connector/amqp.rb

%post
/bin/chgrp libra_user /etc/mcollective/client.cfg

%changelog
* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.2-1
- move client.cfg update to the right place (dmcphers@redhat.com)

* Wed May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Fixing build root dirs

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
