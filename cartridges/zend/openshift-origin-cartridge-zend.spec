%global cartridgedir %{_libexecdir}/openshift/cartridges/v2/zend
%global frameworkdir %{_libexecdir}/openshift/cartridges/v2/zend

Name:    openshift-origin-cartridge-zend
Version: 0.1.7
Release: 1%{?dist}
Summary: Zend Server cartridge
Group:   Development/Languages
License: ASL 2.0
URL:     https://openshift.redhat.com
Source0: %{name}-%{version}.tar.gz

Requires:      rubygem(openshift-origin-node)
Requires:      openshift-origin-node-util

BuildRequires: git
Requires: mod_bw
Requires: rubygem-builder

Requires: zend-server-php-5.3 >= 5.6.0-11
Requires: php-5.3-mongo-zend-server
Requires: php-5.3-imagick-zend-server
Requires: php-5.3-uploadprogress-zend-server
Requires: php-5.3-java-bridge-zend-server
Requires: php-5.3-optimizer-plus-zend-server
Requires: php-5.3-zend-extensions
Requires: php-5.3-extra-extensions-zend-server
Requires: php-5.3-loader-zend-server

#Obsoletes: openshift-origin-cartridge-zend-5.6

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch

%description
Zend Server cartridge for openshift.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/openshift/cartridges/v2
cp -r * %{buildroot}%{cartridgedir}/

%clean
rm -rf %{buildroot}

%post
%{_sbindir}/oo-admin-cartridge --action install --offline --source %{cartridgedir}
#this copies over files in zend server rpm install that do not work in openshift 
cp -rf %{cartridgedir}/versions/5.6/configuration/shared-files/usr/local/zend/* /usr/local/zend/
sh %{cartridgedir}/versions/5.6/configuration/zend_configure_filesystem.sh


%files
%defattr(-,root,root,-)
%dir %{cartridgedir}
%dir %{cartridgedir}/bin
%dir %{cartridgedir}/hooks
%dir %{cartridgedir}/metadata
%dir %{cartridgedir}/versions
%attr(0755,-,-) %{cartridgedir}/bin/
%attr(0755,-,-) %{cartridgedir}/hooks/
%attr(0755,-,-) %{frameworkdir}
%{cartridgedir}/metadata/manifest.yml
%doc %{cartridgedir}/README.md


%changelog
* Mon Apr 29 2013 Adam Miller <admiller@redhat.com> 0.1.7-1
- Bug 957073 (dmcphers@redhat.com)

* Thu Apr 25 2013 Adam Miller <admiller@redhat.com> 0.1.6-1
- zend work (dmcphers@redhat.com)

* Thu Apr 25 2013 Dan McPherson <dmcphers@redhat.com> 0.1.5-1
- 

* Thu Apr 25 2013 Dan McPherson <dmcphers@redhat.com> 0.1.4-1
- 

* Wed Apr 24 2013 Dan McPherson <dmcphers@redhat.com> 0.1.3-1
- new package built with tito

* Wed Apr 24 2013 Vojtech Vitek (V-Teq) <vvitek@redhat.com>
- Zend v2 init (vvitek@redhat.com)

* Tue Apr 23 2013 Vojtech Vitek (V-Teq) <vvitek@redhat.com>
- init package built with tito

