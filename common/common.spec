Summary:   Common dependencies of the libra server and node
Name:      rhc-common
Version: 0.79.1
Release:   1%{?dist}
Group:     Network/Daemons
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-common-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  mcollective-client = 1.1.2
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

%pre
/usr/sbin/groupadd -r libra_user 2>&1 || :

%post
/bin/chgrp libra_user /etc/mcollective/client.cfg

%changelog
* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.79.1-1
- bumping spec versions (admiller@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.78.2-1
- Work with version 14.4 of qpid (dmcphers@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.78.1-1
- bumping spec versions (admiller@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.77.2-1
- release bump for tag uniqueness (mmcgrath@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.76.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.75.2-1
- 

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.75.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.74.2-1
- 

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.74.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Nov 18 2011 Dan McPherson <dmcphers@redhat.com> 0.73.3-1
- more php settings + mirage devenv additions (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.2-1
- 

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Jun 09 2011 Matt Hicks <mhicks@redhat.com> 0.72.3-1
- Reformatting and cleanup (mhicks@redhat.com)
- Retrying on initial connection failure (mhicks@redhat.com)

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.2-1
- move client.cfg update to the right place (dmcphers@redhat.com)

* Wed May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Fixing build root dirs

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
