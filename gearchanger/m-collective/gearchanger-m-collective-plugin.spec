%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname gearchanger-m-collective-plugin
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        GearChanger plugin for m-colective service
Name:           rubygem-%{gemname}
Version: 0.11.3
Release:        1%{?dist}
Group:          Development/Languages
License:        ASL 2.0
URL:            http://openshift.redhat.com
Source0:        rubygem-%{gemname}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(stickshift-common)
Requires:       rubygem(json)

BuildRequires:  ruby
BuildRequires:  rubygems
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %version

%package -n ruby-%{gemname}
Summary:        GearChanger plugin for m-colective based node/gear manager
Requires:       rubygem(%{gemname}) = %version
Provides:       ruby(%{gemname}) = %version

%description
GearChanger plugin for m-colective based node/gear manager

%description -n ruby-%{gemname}
GearChanger plugin for m-collective based node/gear manager

%prep
%setup -q

%build

%post

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
mkdir -p %{buildroot}%{ruby_sitelib}

# Build and install into the rubygem structure
gem build %{gemname}.gemspec
gem install --local --install-dir %{buildroot}%{gemdir} --force %{gemname}-%{version}.gem

# Symlink into the ruby site library directories
ln -s %{geminstdir}/lib/%{gemname} %{buildroot}%{ruby_sitelib}
ln -s %{geminstdir}/lib/%{gemname}.rb %{buildroot}%{ruby_sitelib}

%clean
rm -rf %{buildroot}                                

%files
%defattr(-,root,root,-)
%dir %{geminstdir}
%doc %{geminstdir}/Gemfile
%{gemdir}/doc/%{gemname}-%{version}
%{gemdir}/gems/%{gemname}-%{version}
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

%files -n ruby-%{gemname}
%{ruby_sitelib}/%{gemname}
%{ruby_sitelib}/%{gemname}.rb

%changelog
* Fri Jun 08 2012 Adam Miller <admiller@redhat.com> 0.11.3-1
- dont perform pre-move when moving within same district (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- fix move_gear on messaging about idle/running/stopped on a cartridge basis;
  clean out fix-runaway; cleanout old move-app (rchopra@redhat.com)
- name change (dmcphers@redhat.com)
- add secondary algorithm more expensive algorithm for find available node
  (dmcphers@redhat.com)

* Mon Jun 04 2012 Adam Miller <admiller@redhat.com> 0.11.2-1
- update migration for 2.0.13 and fix gear dns fixup with scaled apps
  (dmcphers@redhat.com)

* Fri Jun 01 2012 Adam Miller <admiller@redhat.com> 0.11.1-1
- bumping spec versions (admiller@redhat.com)

* Wed May 30 2012 Adam Miller <admiller@redhat.com> 0.10.8-1
- fix for bug#826424 - haproxy needs an explicit stop after execute connections
  if it was stopped before already (rchopra@redhat.com)
- updates to move_gear based on review by dmcphers (rchopra@redhat.com)
- formatting fixes (dmcphers@redhat.com)

* Tue May 29 2012 Adam Miller <admiller@redhat.com> 0.10.7-1
- dont call deconfigure on embedded cartridges (rchopra@redhat.com)

* Fri May 25 2012 Adam Miller <admiller@redhat.com> 0.10.6-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- fix bugs 824433 and 824040 and 824375 (rchopra@redhat.com)
- fix for bug#824375 (rchopra@redhat.com)

* Wed May 23 2012 Adam Miller <admiller@redhat.com> 0.10.5-1
- [mpatel+ramr] Fix issues where app_name is not the same as gear_name - fixups
  for typeless gears. (ramr@redhat.com)

* Tue May 22 2012 Dan McPherson <dmcphers@redhat.com> 0.10.4-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Merge branch 'master' into US2109 (rmillner@redhat.com)
- Merge branch 'master' into US2109 (jhonce@redhat.com)
- Bug fix use gear.name for scalable apps to match up passing the right name
  down. (ramr@redhat.com)
- Bugz 820902 (kraman@gmail.com)
- fix for bug#811576 (rchopra@redhat.com)
- Bug fixes for scalable apps + add some debug logging. (ramr@redhat.com)

* Tue May 22 2012 Adam Miller <admiller@redhat.com> 0.10.3-1
- fix haproxy move gear to successfully rsync with correct permissions when
  moving across district. more fixes with deconfigure on the old container
  (rchopra@redhat.com)

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.10.2-1
- remove preconfigure (dmcphers@redhat.com)
- favor servers with capacity < 80 first followed by a weighted average
  favoring emptier servers first (dmcphers@redhat.com)
- Bugz 820902 (kraman@gmail.com)
- fix for bug#811576 (rchopra@redhat.com)

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.10.1-1
- for runaway gears, make sure the move to a new district maintains the
  node_profile (rchopra@redhat.com)
- bumping spec versions (admiller@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.9.5-1
- Bugz# 819984. Update gear dns entried when app namespace is updated
  (kraman@gmail.com)
- move_gear should not allow haproxy gear to be moved until the cartridge is
  fixed. rhc-admin-move should filter scalable apps and act accordingly
  (rchopra@redhat.com)
- fix for bug#819074 - fix gears that have uids out of sync with district
  (rchopra@redhat.com)

* Tue May 08 2012 Adam Miller <admiller@redhat.com> 0.9.4-1
- move_gear : run the framework move hook on haproxy even though it is an
  embedded cart (rchopra@redhat.com)
- prevent a scalable app from moving (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- final fixes for move_gear (rchopra@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.9.3-1
- adding mcollective call to fetch the application state from the .state file
  on each gear (abhgupta@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.9.2-1
- disabling scalable application move through new code until its fully tested
  (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@unused-32-116.sjc.redhat.com)
- move_gear : handle failure cases and perform recovery
  (rchopra@unused-32-116.sjc.redhat.com)
- Cleanup. (mpatel@redhat.com)
- Changes to make inline library calls for ss commands. (mpatel@redhat.com)
- BugZ 817170. Add ability to get valid gear size options from the
  ApplicationContainerProxy (kraman@gmail.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- move_gear updates : gear move should work independent of move_scalable_app
  (rchopra@redhat.com)
- stop at 100 (dmcphers@redhat.com)
- enforce 100 active capacity even in district and add some randomness around
  which node to pick (dmcphers@redhat.com)
- add comment (dmcphers@redhat.com)

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.9.1-1
- bumping spec versions (admiller@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 0.8.9-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- bug fixes in move_scalable_app (rchopra@redhat.com)
- throw error with no uid found on move (dmcphers@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 0.8.8-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- gearchanger-mcollective: fix update namespace for scalable apps
  (rpenta@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.8.7-1
- move_gear for scalable apps... needs more testing, but doesnt break existing
  code (rchopra@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 0.8.6-1
- forcing builds (dmcphers@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 0.8.4-1
- moved a little too much (dmcphers@redhat.com)
- moving our os code (dmcphers@redhat.com)
- add new Gemfile deps to release script (dmcphers@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 0.8.3-1
- new package built with tito

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.8.2-1
- release bump for tag uniqueness (mmcgrath@redhat.com)

* Tue Apr 10 2012 Mike McGrath <mmcgrath@redhat.com> 0.7.7-1
- bug 810475 (bdecoste@gmail.com)

* Mon Apr 09 2012 Mike McGrath <mmcgrath@redhat.com> 0.7.6-1
- Bunping gem version in Gemfile.lock Fix rename issue in application container
  proxy (kraman@gmail.com)
- Merge remote-tracking branch 'origin/master' (kraman@gmail.com)
- Bug fixes after initial merge of OSS packages (kraman@gmail.com)

* Mon Apr 02 2012 Krishna Raman <kraman@gmail.com> 0.7.5-1
- 1) changes to fix remote job creation to work for express as well as
  stickshift.  2) adding resource_limits.conf file to stickshift node.  3)
  adding implementations of generating remote job objects in mcollective
  application container proxy (abhgupta@redhat.com)

* Fri Mar 30 2012 Krishna Raman <kraman@gmail.com> 0.7.4-1
- Renaming for open-source release

