%define cartridgedir %{_libexecdir}/li/cartridges/php-5.3

Summary:   Provides php-5.3 support
Name:      rhc-cartridge-php-5.3
Version:   0.72.5
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-cartridge-php-5.3-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-node
Requires:  php >= 5.3.2
Requires:  php < 5.4.0
Requires:  mod_bw
Requires:  rubygem-builder
Requires:  php-pdo
Requires:  php-gd
Requires:  php-xml
Requires:  php-mysql
Requires:  php-pgsql

BuildArch: noarch

%description
Provides php support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
cp -r . %{buildroot}%{cartridgedir}
rm %{buildroot}%{cartridgedir}/php-5.3.spec

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/data/
%attr(0750,-,-) %{cartridgedir}/info/build/
%{cartridgedir}/info/configuration/
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.5-1
- 

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.4-1
- Automatic commit of package [rhc-cartridge-php-5.3] release [0.72.3-1].
  (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.3-1
- move common files to abstract httpd (dmcphers@redhat.com)
- remove apptype dir part 1 (dmcphers@redhat.com)
- add base concept of parent cartridge - work in progress (dmcphers@redhat.com)
- app-uuid patch from dev/markllama/app-uuid
  69b077104e3227a73cbf101def9279fe1131025e (markllama@gmail.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- Fixing upload tmp dir (mmcgrath@redhat.com)
- Bug 707108 (dmcphers@redhat.com)
- fix issue after refactor with remote clone (dmcphers@redhat.com)

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-3
- Removing spec from install

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Source location fix

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
