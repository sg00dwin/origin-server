Summary:       Common dependencies of the OpenShift broker and site
Name:          rhc-server-common
Version: 0.94.1
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-server-common-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:      rhc-common
Requires(pre): shadow-utils

BuildArch: noarch

%description
Provides the common group and user objects that secure the OpenShift broker and site.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)

%pre
getent group libra_user >/dev/null || groupadd -r libra_user
getent passwd libra_passenger || \
    useradd -r -g libra_user -d /var/lib/passenger -s /sbin/nologin \
    -c "libra_passenger" libra_passenger

%changelog
* Wed Aug 22 2012 Adam Miller <admiller@redhat.com> 0.94.1-1
- bump_minor_versions for sprint 17 (admiller@redhat.com)

* Thu Aug 09 2012 Adam Miller <admiller@redhat.com> 0.93.2-1
- Remove ruby common code from rhc-server-common (ccoleman@redhat.com)

* Thu Aug 02 2012 Adam Miller <admiller@redhat.com> 0.93.1-1
- bump_minor_versions for sprint 16 (admiller@redhat.com)

* Thu Jul 26 2012 Dan McPherson <dmcphers@redhat.com> 0.92.2-1
- Adding blacklisted words (kraman@gmail.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.92.1-1
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.91.2-1
- new package built with tito

* Fri Jun 01 2012 Adam Miller <admiller@redhat.com> 0.91.1-1
- bumping spec versions (admiller@redhat.com)

* Tue May 29 2012 Adam Miller <admiller@redhat.com> 0.90.2-1
- Bug 820223 820338 820325 (dmcphers@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.90.1-1
- fix up spec versions (dmcphers@redhat.com)
- bumping spec versions (admiller@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.89.1-1
- bumping spec versions (admiller@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.88.2-1
- release bump for tag uniqueness (mmcgrath@redhat.com)

* Fri Mar 02 2012 Dan McPherson <dmcphers@redhat.com> 0.87.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.86.2-1
- Adding mysql because of some cartridge bugs (mmcgrath@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.86.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- cleanup (dmcphers@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- bump spec numbers (dmcphers@redhat.com)
