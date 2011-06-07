%define cartridgedir %{_libexecdir}/li/cartridges/rack-1.1

Summary:   Provides ruby rack support running on Phusion Passenger
Name:      rhc-cartridge-rack-1.1
Version:   0.72.7
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-cartridge-rack-1.1-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-node
Requires:  mod_bw
Requires:  rubygems
Requires:  rubygem-rack >= 1.1.0
#Requires:  rubygem-rack < 1.2.0
Requires:  rubygem-passenger
Requires:  rubygem-passenger-native
Requires:  rubygem-passenger-native-libs
Requires:  mod_passenger
Requires:  rubygem-bundler
Requires:  rubygem-sqlite3
Requires:  ruby-sqlite3
Requires:  ruby-mysql
Requires:  ruby-nokogiri

Obsoletes: rhc-cartridge-rack-1.1.0

# Deps for users
Requires: ruby-RMagick

BuildArch: noarch

%description
Provides rack support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
cp -r . %{buildroot}%{cartridgedir}
rm %{buildroot}%{cartridgedir}/rack-1.1.spec
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/add-module %{buildroot}%{cartridgedir}/info/hooks/add-module
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/info %{buildroot}%{cartridgedir}/info/hooks/info
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/post-install %{buildroot}%{cartridgedir}/info/hooks/post-install
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/post-remove %{buildroot}%{cartridgedir}/info/hooks/post-remove
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/reload %{buildroot}%{cartridgedir}/info/hooks/reload
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/remove-module %{buildroot}%{cartridgedir}/info/hooks/remove-module
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/restart %{buildroot}%{cartridgedir}/info/hooks/restart
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/start %{buildroot}%{cartridgedir}/info/hooks/start
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/status %{buildroot}%{cartridgedir}/info/hooks/status
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/stop %{buildroot}%{cartridgedir}/info/hooks/stop
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/update_namespace %{buildroot}%{cartridgedir}/info/hooks/update_namespace

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/data/
%attr(0750,-,-) %{cartridgedir}/info/build/
%config(noreplace) %{cartridgedir}/info/configuration/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.7-1
- moving to sym links for actions (dmcphers@redhat.com)

* Mon Jun 06 2011 Mike McGrath <mmcgrath@redhat.com> 0.72.6-2
- Added config dir symlink and config(noreplace)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.6-1
- version cleanup (dmcphers@redhat.com)
- customer -> application rename in cartridges (dmcphers@redhat.com)
- Adding RPM Obsoletes to make upgrade cleaner (mhicks@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.5-1
- 

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.4-1
- Automatic commit of package [rhc-cartridge-rack-1.1] release [0.72.3-1].
  (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.3-1
- move common files to abstract httpd (dmcphers@redhat.com)
- remove apptype dir part 1 (dmcphers@redhat.com)
- add base concept of parent cartridge - work in progress (dmcphers@redhat.com)
- app-uuid patch from dev/markllama/app-uuid
  69b077104e3227a73cbf101def9279fe1131025e (markllama@gmail.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- Adding ruby-RMagick requirement (mmcgrath@redhat.com)
- Bug 707108 (dmcphers@redhat.com)
- fix issue after refactor with remote clone (dmcphers@redhat.com)

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
