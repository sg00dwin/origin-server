%define cartridgedir %{_libexecdir}/li/cartridges/embedded/cron-1.4

Name: rhc-cartridge-cron-1.4
Version: 0.1.5
Release: 1%{?dist}
Summary: Embedded cron support for express

Group: Network/Daemons
License: ASL 2.0
URL: https://engineering.redhat.com/trac/Libra
Source0: %{name}-%{version}.tar.gz
BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch: noarch

Requires: rhc-node
Requires: cronie


%description
Provides rhc cron cartridge support

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
mkdir -p %{buildroot}/%{_sysconfdir}/cron.d
mkdir -p %{buildroot}/%{_sysconfdir}/cron.minutely
mkdir -p %{buildroot}/%{_sysconfdir}/cron.hourly
mkdir -p %{buildroot}/%{_sysconfdir}/cron.daily
mkdir -p %{buildroot}/%{_sysconfdir}/cron.weekly
mkdir -p %{buildroot}/%{_sysconfdir}/cron.monthly
cp jobs/1minutely %{buildroot}/%{_sysconfdir}/cron.d
cp -r info %{buildroot}%{cartridgedir}/
cp -r jobs %{buildroot}%{cartridgedir}/
cp LICENSE %{buildroot}%{cartridgedir}/
cp COPYRIGHT %{buildroot}%{cartridgedir}/
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
ln -s %{cartridgedir}/jobs/libra-cron-minutely %{buildroot}/%{_sysconfdir}/cron.minutely/
ln -s %{cartridgedir}/jobs/libra-cron-hourly %{buildroot}/%{_sysconfdir}/cron.hourly/
ln -s %{cartridgedir}/jobs/libra-cron-daily %{buildroot}/%{_sysconfdir}/cron.daily/
ln -s %{cartridgedir}/jobs/libra-cron-weekly %{buildroot}/%{_sysconfdir}/cron.weekly/
ln -s %{cartridgedir}/jobs/libra-cron-monthly %{buildroot}/%{_sysconfdir}/cron.monthly/

%post
service crond restart || :


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/build/
%config(noreplace) %{cartridgedir}/info/configuration/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%attr(0755,-,-) %{cartridgedir}/info/lib/
%attr(0755,-,-) %{cartridgedir}/jobs/
%attr(0644,-,-) %{_sysconfdir}/cron.d/1minutely
%attr(0755,-,-) %{_sysconfdir}/cron.minutely/libra-cron-minutely
%attr(0755,-,-) %{_sysconfdir}/cron.hourly/libra-cron-hourly
%attr(0755,-,-) %{_sysconfdir}/cron.daily/libra-cron-daily
%attr(0755,-,-) %{_sysconfdir}/cron.weekly/libra-cron-weekly
%attr(0755,-,-) %{_sysconfdir}/cron.monthly/libra-cron-monthly
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control
%{cartridgedir}/info/manifest.yml
%doc %{cartridgedir}/COPYRIGHT
%doc %{cartridgedir}/LICENSE

%changelog
* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.1.5-1
- Cleanup logging + rename to 1minutely for now. (ramr@redhat.com)
- Fix spec file for minutely addition and pretty print log output.
  (ramr@redhat.com)
- Add minutely freq as per a hallway ("t-shirt" folding) conversation - if its
  too excessive, can be trimmed down to a per-5 minute basis ala the
  competition. (ramr@redhat.com)
- deploy httpd proxy from migration (dmcphers@redhat.com)
- Keep only the last log 2 log files around. tidy doesn't look to clean
  embedded cartridge log files. (ramr@redhat.com)

* Wed Jan 25 2012 Dan McPherson <dmcphers@redhat.com> 0.1.4-1
- Log messages if user's $freq job exceeds max run time. (ramr@redhat.com)
- Add run time limits + added some log messages for auditing purposes.
  (ramr@redhat.com)
- Cleanup message displayed when cron is embedded into the app.
  (ramr@redhat.com)
- More bug fixes. (ramr@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Fix installation paths. (ramr@redhat.com)
- Install libra wrapper job files. (ramr@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.1.3-1
- Updated License value in manifest.yml files. Corrected Apache Software
  License Fedora short name (jhonce@redhat.com)
- rhc-cartridge-cron-1.4: Modified license to ASL V2 (jhonce@redhat.com)

* Mon Jan 23 2012 Ram Ranganathan <ramr@redhat.com> 0.1.2-1
- new package built with tito

* Tue Jan 17 2012 Ram Ranganathan <ramr@redhat.com> 0.1-1
- Initial packaging
