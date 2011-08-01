%define cartridgedir %{_libexecdir}/li/cartridges/perl-5.10

Summary:   Provides mod_perl support
Name:      rhc-cartridge-perl-5.10
Version:   0.6.6
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: git
Requires:  rhc-node >= 0.69.4
Requires:  mod_perl
Requires:  ImageMagick-perl
Requires:  perl-App-cpanminus
# used to do dep resolving for perl
Requires:  rpm-build

BuildArch: noarch

%description
Provides rhc perl cartridge support

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
* Thu Jul 28 2011 Dan McPherson <dmcphers@redhat.com> 0.6.6-1
- Adding env var bits (mmcgrath@redhat.com)

* Tue Jul 26 2011 Dan McPherson <dmcphers@redhat.com> 0.6.5-1
- Adding .openshift to the git template directory (mmcgrath@redhat.com)
- Adding README (mmcgrath@redhat.com)
- added build scripts to jboss, perl, rack and wsgi (mmcgrath@redhat.com)

* Fri Jul 22 2011 Dan McPherson <dmcphers@redhat.com> 0.6.4-1
- Bug 723784 (dmcphers@redhat.com)

* Fri Jul 22 2011 Dan McPherson <dmcphers@redhat.com> 0.6.3-1
- Bug 724026 (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.6.2-1
- move .config -> .openshift/config (dmcphers@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.6.1-1
- Adding perl env vars (mmcgrath@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- add server identity and namespace auto migrate (dmcphers@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.5.2-1
- Automatic commit of package [rhc-cartridge-perl-5.10] release [0.5.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-perl-5.10] release [0.4.10-1].
  (dmcphers@redhat.com)
- Adding rpm-build to dep list (mmcgrath@redhat.com)
- Automatic commit of package [rhc-cartridge-perl-5.10] release [0.4.9-1].
  (dmcphers@redhat.com)
- move empty readmes to .gitkeeps (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-perl-5.10] release [0.4.8-1].
  (dmcphers@redhat.com)
- update rack readme (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-perl-5.10] release [0.4.7-1].
  (dmcphers@redhat.com)
- move untar above perms (dmcphers@redhat.com)
- back off on calling post receive for now (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-perl-5.10] release [0.4.6-1].
  (edirsh@redhat.com)
- Added deplist info (mmcgrath@redhat.com)
- Adding deplist (mmcgrath@redhat.com)
- call post-receive from configure instead of start (dmcphers@redhat.com)
- Automatic commit of package [rhc-cartridge-perl-5.10] release [0.4.5-1].
  (dmcphers@redhat.com)
- undo passing rhlogin to cart (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Automatic commit of package [rhc-cartridge-perl-5.10] release [0.4.4-1].
  (mmcgrath@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.5.1-1
- bumping spec numbers (dmcphers@redhat.com)

* Sat Jul 09 2011 Dan McPherson <dmcphers@redhat.com> 0.4.10-1
- Adding rpm-build to dep list (mmcgrath@redhat.com)

* Thu Jul 07 2011 Dan McPherson <dmcphers@redhat.com> 0.4.9-1
- move empty readmes to .gitkeeps (dmcphers@redhat.com)

* Tue Jul 05 2011 Dan McPherson <dmcphers@redhat.com> 0.4.8-1
- update rack readme (dmcphers@redhat.com)

* Fri Jul 01 2011 Dan McPherson <dmcphers@redhat.com> 0.4.7-1
- move untar above perms (dmcphers@redhat.com)
- back off on calling post receive for now (dmcphers@redhat.com)

* Fri Jul 01 2011 Emily Dirsh <edirsh@redhat.com> 0.4.6-1
- Added deplist info (mmcgrath@redhat.com)
- Adding deplist (mmcgrath@redhat.com)
- call post-receive from configure instead of start (dmcphers@redhat.com)

* Wed Jun 29 2011 Dan McPherson <dmcphers@redhat.com> 0.4.5-1
- undo passing rhlogin to cart (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)

* Wed Jun 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.4.4-1
- 

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.4.3-1
- add back bundling (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.4.2-1
- add wait for stop to finish (dmcphers@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.4.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.3.12-1
- remove comments for bundling code (dmcphers@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.3.11-1
- disabling hooks for perl (mmcgrath@redhat.com)
- Auto finding deps (mmcgrath@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.3.10-1
- Bug 714868 (dmcphers@redhat.com)

* Mon Jun 20 2011 Dan McPherson <dmcphers@redhat.com> 0.3.9-1
- 

* Mon Jun 20 2011 Dan McPherson <dmcphers@redhat.com> 0.3.8-1
- adding template files (dmcphers@redhat.com)
- Temporary commit to build client (dmcphers@redhat.com)
- supressing timestamp warnings (mmcgrath@redhat.com)
- Bug 714575 (dmcphers@redhat.com)
- Bug 714582 (dmcphers@redhat.com)

* Sat Jun 18 2011 Dan McPherson <dmcphers@redhat.com> 0.3.7-1
- Added cpanminus (mmcgrath@redhat.com)
- Properly escaping var (mmcgrath@redhat.com)
- Fixing syntax error (mmcgrath@redhat.com)
- Correcting shell out escaping call (mmcgrath@redhat.com)
- creating new perl repo with the deplist.txt file (mmcgrath@redhat.com)
- Adding repolib (mmcgrath@redhat.com)
- escaping some bash bits (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Adding env vars and new perl5 and cpanm bits (mmcgrath@redhat.com)
- Enabling htaccess (mmcgrath@redhat.com)

* Fri Jun 17 2011 Dan McPherson <dmcphers@redhat.com> 0.3.6-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- removing /perl/ from app dir (mmcgrath@redhat.com)

* Fri Jun 17 2011 Dan McPherson <dmcphers@redhat.com> 0.3.5-1
- Removing /perl/ from app path (mmcgrath@redhat.com)
- fixing GIT_DIR perms (mmcgrath@redhat.com)

* Wed Jun 15 2011 Dan McPherson <dmcphers@redhat.com> 0.3.4-1
- server side bundling for rails 3 (dmcphers@redhat.com)
- use git clone for perl cart (dmcphers@redhat.com)
- Fixed git creation (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- removing old repo (mmcgrath@redhat.com)
- added perl repo (mmcgrath@redhat.com)
- add stop/start to git push (dmcphers@redhat.com)
- move context to libra service and configure Part 2 (dmcphers@redhat.com)
- move context to libra service and configure (dmcphers@redhat.com)

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.3.3-1
- 

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
