%define cartridgedir %{_libexecdir}/li/cartridges/jbossas-7.0

Summary:   Provides JBossAS7 support
Name:      rhc-cartridge-jbossas-7.0
Version:   0.72.19
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc-node
Requires:  jboss-as7-7.0.0.Beta6OS

BuildArch: noarch

%description
Provides JBossAS7 support to OpenShift

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
cp -r . %{buildroot}%{cartridgedir}
rm %{buildroot}%{cartridgedir}/jbossas-7.0.spec
rm %{buildroot}%{cartridgedir}/.gitignore
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/add-module %{buildroot}%{cartridgedir}/info/hooks/add-module
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/info %{buildroot}%{cartridgedir}/info/hooks/info
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/post-install %{buildroot}%{cartridgedir}/info/hooks/post-install
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/post-remove %{buildroot}%{cartridgedir}/info/hooks/post-remove
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/reload %{buildroot}%{cartridgedir}/info/hooks/reload
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/remove-module %{buildroot}%{cartridgedir}/info/hooks/remove-module
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/restart %{buildroot}%{cartridgedir}/info/hooks/restart
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/start %{buildroot}%{cartridgedir}/info/hooks/start
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
%{cartridgedir}/README

%changelog
* Fri Jun 17 2011 Dan McPherson <dmcphers@redhat.com> 0.72.19-1
- fixup dep version (dmcphers@redhat.com)

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.18-1
- 

* Thu Jun 16 2011 Dan McPherson <dmcphers@redhat.com> 0.72.17-1
- Add comment about logs link (scott.stark@jboss.org)
- Create a link from the standalone/log directory to ${APP_DIR}/logs for rhc-
  tail-files (scott.stark@jboss.org)
- Explicity declare dependency on version jboss-7.0.0.Beta6OS of jboss-as7
  (scott.stark@jboss.org)

* Thu Jun 16 2011 Scott Stark <sstark@redhat.com> 0.72.16-1
- Explicity declare dependency on version jboss-7.0.0.Beta6OS of jboss-as7
- Create a link from the standalone/log directory to ${APP_DIR}/logs for rhc-tail-files

* Wed Jun 15 2011 Dan McPherson <dmcphers@redhat.com> 0.72.15-1
- server side bundling for rails 3 (dmcphers@redhat.com)
- Update to jboss-as7 7.0.0.Beta6OS, brew buildID=167639
  (scott.stark@jboss.org)
- add stop/start to git push (dmcphers@redhat.com)
- move context to libra service and configure Part 2 (dmcphers@redhat.com)
- move context to libra service and configure (dmcphers@redhat.com)

* Tue Jun 14 2011 Scott Stark <sstark@redhat.com> 0.72.15-1
- Update standalone.xml configuration for jbossas-7.0.0.Beta6OS

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.14-1
- Spec cleanup (mhicks@redhat.com)
- Permanent jboss fix now in place (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (scott.stark@jboss.org)
- Improve the way the control script is generated and correct the output of the
  status command. (scott.stark@jboss.org)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.13-1
- Add link to sample source Update H2DS to have local file store under
  jboss.server.data.dir (scott.stark@jboss.org)

* Wed Jun 08 2011 Dan McPherson <dmcphers@redhat.com> 0.72.12-1
- fixing configuration dir (mmcgrath@redhat.com)

* Tue Jun 07 2011 Matt Hicks <mhicks@redhat.com> 0.72.11-1
- Fixing servername to remove the debug server (mmcgrath@redhat.com)

* Tue Jun 07 2011 Matt Hicks <mhicks@redhat.com> 0.72.9-1
- Fixing git clone to repack after cloning (mhicks@redhat.com)
- tracking symlink dir (mmcgrath@redhat.com)
- Changing config dir to an actual config.  Also symlinking changes into the
  /etc/libra dir (mmcgrath@redhat.com)
- adding node_ssl_template (mmcgrath@redhat.com)

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.8-1
- moving to sym links for actions (dmcphers@redhat.com)

* Mon Jun 06 2011 Mike McGrath <mmcgrath@redhat.com> 0.72.7-2
- Added config dir symlink and config(noreplace)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.7-1
- Fixing jboss selinux issues (mmcgrath@redhat.com)
- customer -> application rename in cartridges (dmcphers@redhat.com)

* Fri Jun 03 2011 Mike McGrath <mmcgrath@redhat.com> 0.72.6-2
- Added semanage bits

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.6-1
- 

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.5-1
- Automatic commit of package [rhc-cartridge-jbossas-7.0] release [0.72.4-1].
  (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.4-1
- move common files to abstract httpd (dmcphers@redhat.com)
- remove apptype dir part 1 (dmcphers@redhat.com)
- missed 1 delete (dmcphers@redhat.com)
- app-uuid patch from dev/markllama/app-uuid
  69b077104e3227a73cbf101def9279fe1131025e (markllama@gmail.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.3-1
- Update the README with the new brew build task info for jboss-as7 rpm
  (scott.stark@jboss.org)
- Bug 707108 (dmcphers@redhat.com)
- Update the jboss cartridge to use jboss-as7-7.0.0.Beta5OS
  https://brewweb.devel.redhat.com//buildinfo?buildID=165385
  (scott.stark@jboss.org)
- fix issue after refactor with remote clone (dmcphers@redhat.com)
* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- Another cartridge rename to include minor version

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Minor spec cleanup

* Tue May 25 2011 Scott Stark sstark@redhat.com
- change cartridge location to cartridges/jbossas7

* Tue May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
