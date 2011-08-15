%define cartridgedir %{_libexecdir}/li/cartridges/rack-1.1

Summary:   Provides ruby rack support running on Phusion Passenger
Name:      rhc-cartridge-rack-1.1
Version:   0.76.3
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: git
Requires:  rhc-node
Requires:  mod_bw
Requires:  sqlite-devel
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
Requires:  mysql-devel
Requires:  ruby-devel
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
rm -rf git_template
cp -r template/ git_template/
cd git_template
git init
git add -f .
git commit -m 'Creating template'
cd ..
git clone --bare git_template git_template.git
rm -rf git_template
touch git_template.git/refs/heads/.gitignore

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
cp -r info %{buildroot}%{cartridgedir}/
mkdir -p %{buildroot}%{cartridgedir}/info/data/
cp -r git_template.git %{buildroot}%{cartridgedir}/info/data/
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
%attr(0755,-,-) %{cartridgedir}/info/bin/
%config(noreplace) %{cartridgedir}/info/configuration/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Sun Aug 14 2011 Dan McPherson <dmcphers@redhat.com> 0.76.3-1
- Added new scripted snapshot (mmcgrath@redhat.com)
- Adding custom snapshot (mmcgrath@redhat.com)
- reducing output for restore (mmcgrath@redhat.com)
- Added rhcsh, as well as _RESTORE functionality (mmcgrath@redhat.com)
- Adding additional output, also running pre and post hooks of git
  (mmcgrath@redhat.com)
- add stop deploy start to restore (dmcphers@redhat.com)
- functional restore (dmcphers@redhat.com)

* Fri Aug 12 2011 Matt Hicks <mhicks@redhat.com> 0.76.2-1
- silence file-not-found from lsof when killing processes on non-existant logs
  (markllama@redhat.com)

* Fri Aug 05 2011 Dan McPherson <dmcphers@redhat.com> 0.76.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Aug 05 2011 Dan McPherson <dmcphers@redhat.com> 0.75.9-1
- Adding DNS name for reference (mmcgrath@redhat.com)

* Thu Jul 28 2011 Dan McPherson <dmcphers@redhat.com> 0.75.8-1
- adding skip build and markers (dmcphers@redhat.com)
- Adding env var bits (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- one more s/repo/deploy/ fix (mmcgrath@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.75.7-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Correcting rack repo dir to deploy (mmcgrath@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.75.6-1
- Adding .openshift to the git template directory (mmcgrath@redhat.com)
- Adding README (mmcgrath@redhat.com)
- added build scripts to jboss, perl, rack and wsgi (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- import environment variables as part of the git hooks (mmcgrath@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.75.5-1
- Adding environment variables to rack (mmcgrath@redhat.com)

* Fri Jul 22 2011 Dan McPherson <dmcphers@redhat.com> 0.75.4-1
- Bug 723784 (dmcphers@redhat.com)

* Fri Jul 22 2011 Dan McPherson <dmcphers@redhat.com> 0.75.3-1
- Bug 724026 (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.2-1
- move .config -> .openshift/config (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.1-1
- removing PassengerTempDir location now that polyinst works
  (mmcgrath@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- add server identity and namespace auto migrate (dmcphers@redhat.com)

* Fri Jul 15 2011 Dan McPherson <dmcphers@redhat.com> 0.74.3-1
- add mysql-devel as dep (dmcphers@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.74.2-1
- Automatic commit of package [rhc-cartridge-rack-1.1] release [0.74.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-rack-1.1] release [0.73.8-1].
  (dmcphers@redhat.com)
- README updates (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-rack-1.1] release [0.73.7-1].
  (dmcphers@redhat.com)
- update rack readme (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-rack-1.1] release [0.73.6-1].
  (dmcphers@redhat.com)
- move untar above perms (dmcphers@redhat.com)
- back off on calling post receive for now (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-rack-1.1] release [0.73.5-1].
  (edirsh@redhat.com)
- call post-receive from configure instead of start (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-rack-1.1] release [0.73.4-1].
  (dmcphers@redhat.com)
- undo passing rhlogin to cart (dmcphers@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.74.1-1
- bumping spec numbers (dmcphers@redhat.com)

* Tue Jul 05 2011 Dan McPherson <dmcphers@redhat.com> 0.73.8-1
- README updates (dmcphers@redhat.com)

* Tue Jul 05 2011 Dan McPherson <dmcphers@redhat.com> 0.73.7-1
- update rack readme (dmcphers@redhat.com)

* Fri Jul 01 2011 Dan McPherson <dmcphers@redhat.com> 0.73.6-1
- move untar above perms (dmcphers@redhat.com)
- back off on calling post receive for now (dmcphers@redhat.com)

* Fri Jul 01 2011 Emily Dirsh <edirsh@redhat.com> 0.73.5-1
- call post-receive from configure instead of start (dmcphers@redhat.com)

* Wed Jun 29 2011 Dan McPherson <dmcphers@redhat.com> 0.73.4-1
- undo passing rhlogin to cart (dmcphers@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.3-1
- add wait for stop to finish (dmcphers@redhat.com)
- add back gem bundling (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.2-1
- Automatic commit of package [rhc-cartridge-rack-1.1] release [0.73.1-1].
  (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.72.19-1
- remove comments for bundling code (dmcphers@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.72.18-1
- remove rails bundling until next iteration (dmcphers@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.72.17-1
- Bug 714868 (dmcphers@redhat.com)

* Mon Jun 20 2011 Dan McPherson <dmcphers@redhat.com> 0.72.16-1
- 

* Mon Jun 20 2011 Dan McPherson <dmcphers@redhat.com> 0.72.15-1
- adding template files (dmcphers@redhat.com)
- Temporary commit to build client (dmcphers@redhat.com)
- supressing timestamp warnings (mmcgrath@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.14-1
- add sqlitedevel to spec (dmcphers@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.13-1
- better messaging for bundling process (dmcphers@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.12-1
- allow .force_clean_build (dmcphers@redhat.com)

* Wed Jun 15 2011 Dan McPherson <dmcphers@redhat.com> 0.72.11-1
- server side bundling for rails 3 (dmcphers@redhat.com)
- fix tmpdir (dmcphers@redhat.com)
- add tmp dir to rack apps (dmcphers@redhat.com)
- add stop/start to git push (dmcphers@redhat.com)
- move context to libra service and configure Part 2 (dmcphers@redhat.com)
- move context to libra service and configure (dmcphers@redhat.com)

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.10-1
- Spec cleanup (mhicks@redhat.com)

* Tue Jun 07 2011 Matt Hicks <mhicks@redhat.com> 0.72.9-1
- Fixing servername to remove the debug server (mmcgrath@redhat.com)
- specifying full path for rack apps (mmcgrath@redhat.com)

* Tue Jun 07 2011 Matt Hicks <mhicks@redhat.com> 0.72.8-1
- Fixing git clone to repack after cloning (mhicks@redhat.com)
- tracking symlink dir (mmcgrath@redhat.com)
- Changing config dir to an actual config.  Also symlinking changes into the
  /etc/libra dir (mmcgrath@redhat.com)
- adding node_ssl_template (mmcgrath@redhat.com)

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
