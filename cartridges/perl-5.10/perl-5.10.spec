%define cartridgedir %{_libexecdir}/li/cartridges/perl-5.10

Summary:   Provides mod_perl support
Name:      rhc-cartridge-perl-5.10
Version:   0.3.2
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-node >= 0.69.4
Requires:  mod_perl
Requires:  ImageMagick-perl

BuildArch: noarch

%description
Provides rhc perl cartridge support

%prep
%setup -q

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
cp -r . %{buildroot}%{cartridgedir}
rm %{buildroot}%{cartridgedir}/perl-5.10.spec
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
rm -rf $RPM_BUILD_ROOT

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
* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.3.2-1
- removing minor version release reference (mmcgrath@redhat.com)
- Spec cleanup (mhicks@redhat.com)
- Perl cartridge spec fixes (mhicks@redhat.com)
- removing php reference (mmcgrath@redhat.com)
- following common name usage (mmcgrath@redhat.com)

* Tue Jun 14 2011 Mike McGrath <mmcgrath@redhat.com> 0.3-1
- new package built with tito

* Tue Jun 14 2011 Mike McGrath <mmcgrath@redhat.com> 0.2-1
- Starting repackaging for main repo

* Fri May 27 2011 Mike McGrath <mmcgrath@redhat.com> 0.1-2
- Added ImageMagick-perl req

* Mon May 16 2011 Mike McGrath <mmcgrath@redhat.com> 0.1-1
- Added rake BR

* Mon May 16 2011 Mike McGrath <mmcgrath@redhat.com> 0.1-1
- Initial packaging
