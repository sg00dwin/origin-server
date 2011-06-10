%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

Summary:       Multi-tenant cloud management system client tools
Name:          rhc
Version:       0.72.12
Release:       1%{?dist}
Group:         Network/Daemons
License:       MIT
URL:           http://openshift.redhat.com
Source0:       rhc-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: rubygem-rake
BuildRequires: rubygem-rspec
Requires:      ruby >= 1.8.7
Requires:      rubygem-parseconfig
Requires:      rubygem-json
Requires:      git

BuildArch:     noarch

%description
Provides OpenShift client libraries

%prep
%setup -q

%build
for f in bin/rhc-*
do
  ruby -c $f
done

for f in lib/*.rb
do
  ruby -c $f
done

%install
pwd
rm -rf $RPM_BUILD_ROOT

mkdir -p "$RPM_BUILD_ROOT/usr/share/man/man1/"
mkdir -p "$RPM_BUILD_ROOT/usr/share/man/man5/"

for f in man/*
do
  len=`expr length $f`
  manSection=`expr substr $f $len $len`
  cp $f "$RPM_BUILD_ROOT/usr/share/man/man${manSection}/"
done

mkdir -p $RPM_BUILD_ROOT/etc/openshift
if [ ! -f "$RPM_BUILD_ROOT/etc/openshift/express.conf" ]
then
  cp "conf/express.conf" $RPM_BUILD_ROOT/etc/openshift/
fi

# Package the gem
rake package

mkdir -p .%{gemdir}
gem install --install-dir $RPM_BUILD_ROOT/%{gemdir} --bindir $RPM_BUILD_ROOT/%{_bindir} --local -V --force --rdoc \
     pkg/rhc-%{version}.gem

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc doc/USAGE.txt
%{_bindir}/rhc-create-app
%{_bindir}/rhc-create-domain
%{_bindir}/rhc-user-info
%{_bindir}/rhc-ctl-app
%{_bindir}/rhc-snapshot
%{_bindir}/rhc-tail-files
%{_mandir}/man1/rhc-*
%{_mandir}/man5/express*
%{gemdir}/gems/rhc-%{version}/
%{gemdir}/cache/rhc-%{version}.gem
%{gemdir}/doc/rhc-%{version}
%{gemdir}/specifications/rhc-%{version}.gemspec
%config(noreplace) %{_sysconfdir}/openshift/express.conf

%changelog
* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.12-1
- bug 712276 (dmcphers@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.11-1
- Added applicatino name (mmcgrath@redhat.com)

* Thu Jun 09 2011 Dan McPherson <dmcphers@redhat.com> 0.72.10-1
- bug 707857 (dmcphers@redhat.com)

* Thu Jun 09 2011 Matt Hicks <mhicks@redhat.com> 0.72.9-1
- Bug 706353 (dmcphers@redhat.com)
- cleanup (dmcphers@redhat.com)
- Bug 707857 (dmcphers@redhat.com)
- Bug 705703 (dmcphers@redhat.com)
- improve terminology with rhlogin in usage and man pages (dmcphers@redhat.com)

* Wed Jun 08 2011 Dan McPherson <dmcphers@redhat.com> 0.72.8-1
- 

* Wed Jun 08 2011 Dan McPherson <dmcphers@redhat.com> 0.72.7-1
- Bug 711685 (dmcphers@redhat.com)
- fix rhc-snapshot (dmcphers@redhat.com)

* Tue Jun 07 2011 Matt Hicks <mhicks@redhat.com> 0.72.6-1
- Added a curl example (mmcgrath@redhat.com)
- Adding more explicit references in API doc (mmcgrath@redhat.com)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.4-1
- fix breakge no mo pure (jimjag@redhat.com)
- revert (jimjag@redhat.com)
- Move to json/pure for client side (jimjag@redhat.com)
- Adding json string (mmcgrath@redhat.com)
- Added API returns (mmcgrath@redhat.com)
- Switching to json_pure for Mac / Windows (mhicks@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.3-1
- app-uuid patch from dev/markllama/app-uuid
  69b077104e3227a73cbf101def9279fe1131025e (markllama@gmail.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- Bug 707488 (dmcphers@redhat.com)

