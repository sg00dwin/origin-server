%define cartridgedir %{_libexecdir}/li/cartridges/wsgi-3.2

Summary:   Provides python-wsgi-3.2 support
Name:      rhc-cartridge-wsgi-3.2
Version:   0.80.7
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: git
Requires:  rhc-node
Requires:  mod_bw
Requires:  python
Requires:  mod_wsgi = 3.2
Requires:  MySQL-python
Requires:  python-psycopg2
Requires:  python-virtualenv

Obsoletes: rhc-cartridge-wsgi-3.2.1

BuildArch: noarch

%description
Provides wsgi support to OpenShift

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
ln -s %{cartridgedir}/../abstract/info/hooks/add-module %{buildroot}%{cartridgedir}/info/hooks/add-module
ln -s %{cartridgedir}/../abstract/info/hooks/info %{buildroot}%{cartridgedir}/info/hooks/info
ln -s %{cartridgedir}/../abstract/info/hooks/post-install %{buildroot}%{cartridgedir}/info/hooks/post-install
ln -s %{cartridgedir}/../abstract/info/hooks/post-remove %{buildroot}%{cartridgedir}/info/hooks/post-remove
ln -s %{cartridgedir}/../abstract/info/hooks/reload %{buildroot}%{cartridgedir}/info/hooks/reload
ln -s %{cartridgedir}/../abstract/info/hooks/remove-module %{buildroot}%{cartridgedir}/info/hooks/remove-module
ln -s %{cartridgedir}/../abstract/info/hooks/restart %{buildroot}%{cartridgedir}/info/hooks/restart
ln -s %{cartridgedir}/../abstract/info/hooks/start %{buildroot}%{cartridgedir}/info/hooks/start
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/status %{buildroot}%{cartridgedir}/info/hooks/status
ln -s %{cartridgedir}/../abstract/info/hooks/stop %{buildroot}%{cartridgedir}/info/hooks/stop
ln -s %{cartridgedir}/../abstract/info/hooks/update_namespace %{buildroot}%{cartridgedir}/info/hooks/update_namespace
ln -s %{cartridgedir}/../abstract/info/hooks/preconfigure %{buildroot}%{cartridgedir}/info/hooks/preconfigure
ln -s %{cartridgedir}/../abstract/info/hooks/deploy_httpd_proxy %{buildroot}%{cartridgedir}/info/hooks/deploy_httpd_proxy
ln -s %{cartridgedir}/../abstract/info/hooks/force-stop %{buildroot}%{cartridgedir}/info/hooks/force-stop

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
* Wed Oct 19 2011 Dan McPherson <dmcphers@redhat.com> 0.80.7-1
- add ip back to raw (dmcphers@redhat.com)

* Mon Oct 17 2011 Dan McPherson <dmcphers@redhat.com> 0.80.6-1
- add abstract (more generic than httpd)  cart and use from existing carts
  (dmcphers@redhat.com)
- Added support for force-stop (mmcgrath@redhat.com)

* Sun Oct 16 2011 Dan McPherson <dmcphers@redhat.com> 0.80.5-1
- abstract out remainder of deconfigure (dmcphers@redhat.com)

* Sat Oct 15 2011 Dan McPherson <dmcphers@redhat.com> 0.80.4-1
- abstract out common vars in remaining hooks (dmcphers@redhat.com)
- more abstracting (dmcphers@redhat.com)
- more abstracting (dmcphers@redhat.com)
- more abstracting of common code (dmcphers@redhat.com)
- move sources to the top and abstract out error method (dmcphers@redhat.com)
- move simple functions to source files (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.3-1
- abstract destroy git repo and rm httpd proxy (dmcphers@redhat.com)
- Temporary commit to build (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.2-1
- abstract create_repo (dmcphers@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.80.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.13-1
- abstract out find_open_ip (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.12-1
- abstract rm_symlink (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.79.11-1
- abstract out common logic (dmcphers@redhat.com)
- Bug 745373 and remove sessions where not needed (dmcphers@redhat.com)
- correcting odd lib64 symlink issue for virtual envs (mmcgrath@redhat.com)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.79.10-1
- renamed post-deploy to post_deploy for consistency (mmcgrath@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.9-1
- add .m2 syncing (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.8-1
- call build instead of post receive (dmcphers@redhat.com)
- common post receive and add pre deploy (dmcphers@redhat.com)
- add deploy and post-deploy everywhere (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.7-1
- more jenkins job work (dmcphers@redhat.com)
- Added better output on failed builds (mmcgrath@redhat.com)
- Merging (mmcgrath@redhat.com)
- Adding better output for failed / successful jobs (mmcgrath@redhat.com)
- Added better comments (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- correcting URL output (mmcgrath@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.6-1
- ssh -> GIT_SSH (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.79.5-1
- add deploy step and call from jenkins with stop start (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- job updates (dmcphers@redhat.com)
- adding UUID and DNS support (mmcgrath@redhat.com)
- working on jenkins build logic (dmcphers@redhat.com)

* Sun Oct 09 2011 Dan McPherson <dmcphers@redhat.com> 0.79.4-1
- Adding more obvious verbage (mmcgrath@redhat.com)
- A failed jenkins build is a fatal error (mmcgrath@redhat.com)
- prepping for jenkins integration (mmcgrath@redhat.com)

* Thu Oct 06 2011 Dan McPherson <dmcphers@redhat.com> 0.79.3-1
- switch to use ci type to know if client is avail (dmcphers@redhat.com)
- add jenkins build kickoff to all post receives (dmcphers@redhat.com)
- adding base templates for all types (dmcphers@redhat.com)

* Tue Oct 04 2011 Dan McPherson <dmcphers@redhat.com> 0.79.2-1
- cleanup (dmcphers@redhat.com)
- add deploy httpd proxy and migration (dmcphers@redhat.com)
- Adding request header type (mmcgrath@redhat.com)
- added code to remove the new dir that gets created in
  /etc/httpd/conf.d/libra/ for the apache definition stuff (twiest@redhat.com)
- Merge branch 'master' into mmcgrath-conf.d-include (twiest@redhat.com)
- Adding markers for php (mmcgrath@redhat.com)
- fixing wsgi configs (mmcgrath@redhat.com)
- Adding proper include dir (mmcgrath@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.79.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Sep 28 2011 Dan McPherson <dmcphers@redhat.com> 0.78.6-1
- add preconfigure for jenkins to split out auth key gen (dmcphers@redhat.com)

* Mon Sep 26 2011 Dan McPherson <dmcphers@redhat.com> 0.78.5-1
- Added a comment so its more obvious where to start coding
  (mmcgrath@redhat.com)

* Thu Sep 15 2011 Dan McPherson <dmcphers@redhat.com> 0.78.4-1
- updated mcs_level generation for app accounts > 522 (markllama@redhat.com)

* Wed Sep 14 2011 Dan McPherson <dmcphers@redhat.com> 0.78.3-1
- Passing basic authorization information to the applications
  (mhicks@redhat.com)
- Changing default path to be at the end so we can overwrite system utilities
  (mmcgrath@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.78.2-1
- Automatic commit of package [rhc-cartridge-wsgi-3.2] release [0.78.1-1].
  (dmcphers@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.78.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Aug 19 2011 Matt Hicks <mhicks@redhat.com> 0.77.1-1
- fix wsgi apps (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- splitting app_ctl.sh out (dmcphers@redhat.com)

* Wed Aug 17 2011 Dan McPherson <dmcphers@redhat.com> 0.76.7-1
- add app type and db type and migration restart (dmcphers@redhat.com)

* Tue Aug 16 2011 Dan McPherson <dmcphers@redhat.com> 0.76.6-1
- split out post and pre receive from the apps (dmcphers@redhat.com)
- removing default charset (mmcgrath@redhat.com)

* Tue Aug 16 2011 Matt Hicks <mhicks@redhat.com> 0.76.5-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Fixing chcon to include git (mmcgrath@redhat.com)
- splitting out stop/start, changing snapshot to use stop start and bug 730890
  (dmcphers@redhat.com)
- Appending / to dir names (mmcgrath@redhat.com)
- ensuring /tmp ends with a / (mmcgrath@redhat.com)

* Mon Aug 15 2011 Dan McPherson <dmcphers@redhat.com> 0.76.4-1
- adding migration for snapshot/restore (dmcphers@redhat.com)
- snapshot and restore using path (dmcphers@redhat.com)

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

* Mon Aug 01 2011 Dan McPherson <dmcphers@redhat.com> 0.75.8-1
- 

* Mon Aug 01 2011 Dan McPherson <dmcphers@redhat.com> 0.75.7-1
- Added Public Static Dir (mmcgrath@redhat.com)

* Thu Jul 28 2011 Dan McPherson <dmcphers@redhat.com> 0.75.6-1
- adding skip build and markers (dmcphers@redhat.com)
- Adding env var bits (mmcgrath@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.75.5-1
- Adding .openshift to the git template directory (mmcgrath@redhat.com)
- Adding README (mmcgrath@redhat.com)
- added build scripts to jboss, perl, rack and wsgi (mmcgrath@redhat.com)
- import environment variables as part of the git hooks (mmcgrath@redhat.com)

* Fri Jul 22 2011 Dan McPherson <dmcphers@redhat.com> 0.75.4-1
- Bug 723784 (dmcphers@redhat.com)

* Fri Jul 22 2011 Dan McPherson <dmcphers@redhat.com> 0.75.3-1
- Bug 724026 (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.2-1
- move .config -> .openshift/config (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.1-1
- adding wsgi (mmcgrath@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- add server identity and namespace auto migrate (dmcphers@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.74.2-1
- Automatic commit of package [rhc-cartridge-wsgi-3.2] release [0.74.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-wsgi-3.2] release [0.73.7-1].
  (dmcphers@redhat.com)
- Fixing missing setup definition, Bug 718688 (mmcgrath@redhat.com)
- Automatic commit of package [rhc-cartridge-wsgi-3.2] release [0.73.6-1].
  (dmcphers@redhat.com)
- move untar above perms (dmcphers@redhat.com)
- back off on calling post receive for now (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-wsgi-3.2] release [0.73.5-1].
  (edirsh@redhat.com)
- Adding info in the readme about setup.py (mmcgrath@redhat.com)
- Adding setup.py (mmcgrath@redhat.com)
- call post-receive from configure instead of start (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-wsgi-3.2] release [0.73.4-1].
  (dmcphers@redhat.com)
- undo passing rhlogin to cart (dmcphers@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.74.1-1
- bumping spec numbers (dmcphers@redhat.com)

* Tue Jul 05 2011 Dan McPherson <dmcphers@redhat.com> 0.73.7-1
- Fixing missing setup definition, Bug 718688 (mmcgrath@redhat.com)

* Fri Jul 01 2011 Dan McPherson <dmcphers@redhat.com> 0.73.6-1
- move untar above perms (dmcphers@redhat.com)
- back off on calling post receive for now (dmcphers@redhat.com)

* Fri Jul 01 2011 Emily Dirsh <edirsh@redhat.com> 0.73.5-1
- Adding info in the readme about setup.py (mmcgrath@redhat.com)
- Adding setup.py (mmcgrath@redhat.com)
- call post-receive from configure instead of start (dmcphers@redhat.com)

* Wed Jun 29 2011 Dan McPherson <dmcphers@redhat.com> 0.73.4-1
- undo passing rhlogin to cart (dmcphers@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.3-1
- add back bundling (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.2-1
- add wait for stop to finish (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.72.18-1
- remove comments for bundling code (dmcphers@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.72.17-1
- disabling dep resolving for wsgi (mmcgrath@redhat.com)
- Moving virtenv into app dir (mmcgrath@redhat.com)
- Adding 256M as default quota type (mmcgrath@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.72.16-1
- Bug 714868 (dmcphers@redhat.com)

* Mon Jun 20 2011 Dan McPherson <dmcphers@redhat.com> 0.72.15-1
- 

* Mon Jun 20 2011 Dan McPherson <dmcphers@redhat.com> 0.72.14-1
- adding template files (dmcphers@redhat.com)
- Temporary commit to build client (dmcphers@redhat.com)
- supressing timestamp warnings (mmcgrath@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.13-1
- added virtualenv dep (mmcgrath@redhat.com)

* Thu Jun 16 2011 Mike McGrath <mmcgrath@redhat.com> 0.72.12-2
- Added python-virtualenv dep

* Thu Jun 16 2011 Matt Hicks <mhicks@redhat.com> 0.72.12-1
- Added virtenv (mmcgrath@redhat.com)
- added new repo layout (mmcgrath@redhat.com)

* Wed Jun 15 2011 Dan McPherson <dmcphers@redhat.com> 0.72.11-1
- server side bundling for rails 3 (dmcphers@redhat.com)
- add stop/start to git push (dmcphers@redhat.com)
- move context to libra service and configure Part 2 (dmcphers@redhat.com)
- move context to libra service and configure (dmcphers@redhat.com)

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.10-1
- Spec cleanup (mhicks@redhat.com)

* Wed Jun 08 2011 Dan McPherson <dmcphers@redhat.com> 0.72.9-1
- fixing configuration dir (mmcgrath@redhat.com)

* Tue Jun 07 2011 Matt Hicks <mhicks@redhat.com> 0.72.8-1
- Fixing servername to remove the debug server (mmcgrath@redhat.com)

* Tue Jun 07 2011 Matt Hicks <mhicks@redhat.com> 0.72.7-1
- Fixing git clone to repack after cloning (mhicks@redhat.com)
- tracking symlink dir (mmcgrath@redhat.com)
- Changing config dir to an actual config.  Also symlinking changes into the
  /etc/libra dir (mmcgrath@redhat.com)
- adding node_ssl_template (mmcgrath@redhat.com)

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.6-1
- moving to sym links for actions (dmcphers@redhat.com)

* Mon Jun 06 2011 Mike McGrath <mmcgrath@redhat.com> 0.72.5-2
- Added config dir symlink and config(noreplace)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.5-1
- version cleanup (dmcphers@redhat.com)
- customer -> application rename in cartridges (dmcphers@redhat.com)
- Adding RPM Obsoletes to make upgrade cleaner (mhicks@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.4-1
- Automatic commit of package [rhc-cartridge-wsgi-3.2] release [0.72.3-1].
  (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.3-1
- move common files to abstract httpd (dmcphers@redhat.com)
- remove apptype dir part 1 (dmcphers@redhat.com)
- add base concept of parent cartridge - work in progress (dmcphers@redhat.com)
- app-uuid patch from dev/markllama/app-uuid
  69b077104e3227a73cbf101def9279fe1131025e (markllama@gmail.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- Bug 707108 (dmcphers@redhat.com)
- fix issue after refactor with remote clone (dmcphers@redhat.com)

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
