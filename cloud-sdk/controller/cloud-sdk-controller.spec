%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname cloud-sdk-controller
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        Cloud Development Controller
Name:           rubygem-%{gemname}
Version:        0.3.8
Release:        1%{?dist}
Group:          Development/Languages
License:        AGPLv3
URL:            http://openshift.redhat.com
Source0:        rubygem-%{gemname}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(activemodel)
Requires:       rubygem(highline)
Requires:       rubygem(json_pure)
Requires:       rubygem(mocha)
Requires:       rubygem(parseconfig)
Requires:       rubygem(state_machine)
Requires:       rubygem(cloud-sdk-common)

BuildRequires:  ruby
BuildRequires:  rubygems
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %version

%package -n ruby-%{gemname}
Summary:        Cloud Development Controller Library
Requires:       rubygem(%{gemname}) = %version
Provides:       ruby(%{gemname}) = %version

%description
This contains the Cloud Development Controller packaged as a rubygem.

%description -n ruby-%{gemname}
This contains the Cloud Development Controller packaged as a ruby site library.

%prep
%setup -q

%build

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
* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.3.8-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (lnader@dhcp-240-165.mad.redhat.com)
- bug fix in cartridge controller (lnader@dhcp-240-165.mad.redhat.com)
- everything but the delete (lnader@dhcp-240-165.mad.redhat.com)
- bug fixes (lnader@dhcp-240-165.mad.redhat.com)
- Merge remote branch 'origin/master' into REST
  (lnader@dhcp-240-165.mad.redhat.com)
- renamed controllers (lnader@dhcp-240-165.mad.redhat.com)
- bug fixes (lnader@dhcp-240-165.mad.redhat.com)
- Merge branch 'REST' of ssh://git1.ops.rhcloud.com/srv/git/li into REST
  (lnader@dhcp-240-165.mad.redhat.com)
- bug fixes in embedded controller (lnader@dhcp-240-165.mad.redhat.com)
- renamed controller (lnader@dhcp-240-165.mad.redhat.com)
- new event and embedded controller (lnader@dhcp-240-165.mad.redhat.com)
- split app controller into 3 controllers (lnader@dhcp-240-165.mad.redhat.com)
- bug fixes and HTTP status codes in app controller
  (lnader@dhcp-240-165.mad.redhat.com)
- Added new method to auth service with support for user/pass based
  authentication for new REST API (kraman@gmail.com)
- Completed domain api (kraman@gmail.com)
- Cleanup and fixes for routes and REST models (kraman@gmail.com)
- Adding additional routes and fixing merge conflicts (kraman@gmail.com)
- bug fixes (lnader@dhcp-240-165.mad.redhat.com)
- new rest cartridge object (lnader@dhcp-240-165.mad.redhat.com)
- created rest app class (lnader@dhcp-240-165.mad.redhat.com)
- bug fixes and file name changes (lnader@dhcp-240-165.mad.redhat.com)
- REST API bug fixes (lnader@dhcp-240-165.mad.redhat.com)
- REST API bug fixes (lnader@dhcp-240-165.mad.redhat.com)
- controller file renamed (lnader@dhcp-240-165.mad.redhat.com)
- Adding route for domains (kraman@gmail.com)
- Adding user management api routes (kraman@gmail.com)
- REST API revision 3 (lnader@dhcp-240-165.mad.redhat.com)
- XML tags for serialized classes are returned as - seperated words instead of
  camel case (kraman@gmail.com)
- Creating REST routes. Bugfixes (kraman@gmail.com)
- REST API revision 2 (lnader@dhcp-240-165.mad.redhat.com)
- REST API revision (lnader@dhcp-240-165.mad.redhat.com)
- REST API (lnader@dhcp-240-165.mad.redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.3.7-1
- Updating gem versions (dmcphers@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.3.6-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- implementation of US1733 - by default the new field is not saved yet
  (rchopra@redhat.com)

* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.3.5-1
- Updating gem versions (dmcphers@redhat.com)
- fix build (dmcphers@redhat.com)

* Wed Jan 18 2012 Mike McGrath <mmcgrath@redhat.com> 0.3.4-1
- Updating gem versions (mmcgrath@redhat.com)

* Wed Jan 18 2012 Dan McPherson <dmcphers@redhat.com> 0.3.3-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- handle app being removed during migration (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge/resolve conflicts from master (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li into s3-to-mongo
  (rpenta@redhat.com)
- fixes related to mongo datastore (rpenta@redhat.com)
- Added MongoDataStore model (rpenta@redhat.com)

* Tue Jan 17 2012 Dan McPherson <dmcphers@redhat.com> 0.3.2-1
- Updating gem versions (dmcphers@redhat.com)
- fix test case (dmcphers@redhat.com)
- districts (work in progress) (dmcphers@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Raise UserKeyException instead of UserException when dealing with user ssh
  keys (rpenta@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.3.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)
- Bug 781254 (dmcphers@redhat.com)

* Thu Jan 12 2012 Dan McPherson <dmcphers@redhat.com> 0.2.31-1
- Updating gem versions (dmcphers@redhat.com)
- Bump API version to 1.1.2 due to key_type requirement on domain create/update
  (aboone@redhat.com)
- add common to controller deps (dmcphers@redhat.com)
- - Assign default ssh_type when empty string is passed to cloud user.
  (rpenta@redhat.com)

* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.2.30-1
- Updating gem versions (dmcphers@redhat.com)
- remove email from cloud user (dmcphers@redhat.com)
- grammar change in message to user (rchopra@redhat.com)
- typo fix in message (rchopra@redhat.com)
- bugfixes for #773189 and #773139 (rchopra@redhat.com)
- correctly return 400 for invalid requests (dmcphers@redhat.com)

* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.2.29-1
- Updating gem versions (dmcphers@redhat.com)
- Fix for Bugs# 773209, 773176 (rpenta@redhat.com)

* Tue Jan 10 2012 Dan McPherson <dmcphers@redhat.com> 0.2.28-1
- Updating gem versions (dmcphers@redhat.com)
- change identified in code review for bug 772673 (abhgupta@redhat.com)
- Fix for Bug# 772673 -Persist ssh key type in the datastore (currently in s3)
  (rpenta@redhat.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.2.27-1
- Updating gem versions (dmcphers@redhat.com)
- BugzID# 772760 (kraman@gmail.com)
- Move jenkins deconfigure to observer. Create convinence method to move app
  deconfigure and user update logic from admin script and cloud-sdk controller
  to cloud-sdk models. (kraman@gmail.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.2.26-1
- Updating gem versions (dmcphers@redhat.com)
- TA1166: Move outage notification out of cloud-sdk controller to broker
  component (kraman@gmail.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.2.25-1
- Updating gem versions (dmcphers@redhat.com)
- fix test case (dmcphers@redhat.com)
- fixing issues resulting out of code merging (abhgupta@redhat.com)
- Fixes to enable cloud-sdk-controller tests (kraman@gmail.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.2.24-1
- Updating gem versions (dmcphers@redhat.com)
- fix build break and better error messaging (dmcphers@redhat.com)
- US1608: support DSA keys (rpenta@redhat.com)
- US1608: support DSA keys (rpenta@redhat.com)
- bug-fixes related to Mirage/express merge (rpenta@redhat.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.2.23-1
- Updating gem versions (dmcphers@redhat.com)
- better error handling (dmcphers@redhat.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.2.22-1
- Updating gem versions (dmcphers@redhat.com)
- use user exception (dmcphers@redhat.com)
- Adding cloud-sdk-controller unit tests (kraman@gmail.com)

* Wed Jan 04 2012 Dan McPherson <dmcphers@redhat.com> 0.2.21-1
- Updating gem versions (dmcphers@redhat.com)
- better rollback logic (dmcphers@redhat.com)

* Wed Jan 04 2012 Alex Boone <aboone@redhat.com> 0.2.20-1
- Updating gem versions (aboone@redhat.com)

* Wed Jan 04 2012 Alex Boone <aboone@redhat.com> 0.2.19-1
- move fixes (dmcphers@redhat.com)

* Wed Dec 28 2011 Dan McPherson <dmcphers@redhat.com> 0.2.18-1
- Updating gem versions (dmcphers@redhat.com)
- Bug 770544 (dmcphers@redhat.com)

* Tue Dec 27 2011 Dan McPherson <dmcphers@redhat.com> 0.2.17-1
- Updating gem versions (dmcphers@redhat.com)
- various fixes (dmcphers@redhat.com)
- add application limit of 5 (dmcphers@redhat.com)

* Tue Dec 27 2011 Dan McPherson <dmcphers@redhat.com> 0.2.16-1
- Updating gem versions (dmcphers@redhat.com)
- remove version ref (dmcphers@redhat.com)

* Tue Dec 27 2011 Dan McPherson <dmcphers@redhat.com> 0.2.15-1
- Updating gem versions (dmcphers@redhat.com)
- release fixes (dmcphers@redhat.com)
- Bug 770544 (dmcphers@redhat.com)

* Mon Dec 26 2011 Dan McPherson <dmcphers@redhat.com> 0.2.14-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 770406 (dmcphers@redhat.com)

* Fri Dec 23 2011 Dan McPherson <dmcphers@redhat.com> 0.2.13-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 77027 (dmcphers@redhat.com)
- Bug 770085 (dmcphers@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.2.12-1
- bump spec numbers (dmcphers@redhat.com)
- add better error handling for configure errors (dmcphers@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.2.11-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 768851 - allow jboss build with only large instance available (devenv)
  (dmcphers@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.2.10-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 769358 (dmcphers@redhat.com)

* Wed Dec 21 2011 Dan McPherson <dmcphers@redhat.com> 0.2.9-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 769521 (dmcphers@redhat.com)
- Bug 769565 (dmcphers@redhat.com)

* Wed Dec 21 2011 Dan McPherson <dmcphers@redhat.com> 0.2.8-1
- bump spec numbers (dmcphers@redhat.com)
- Bug 769211 (dmcphers@redhat.com)
- fix typo (dmcphers@redhat.com)
- Bug 769663 (dmcphers@redhat.com)
- Bug 769663 (dmcphers@redhat.com)

* Wed Dec 21 2011 Dan McPherson <dmcphers@redhat.com> 0.2.7-1
- fix spec numbers (dmcphers@redhat.com)

* Wed Dec 21 2011 Mike McGrath <mmcgrath@redhat.com> 0.2.6-1
- Bump cartridge list cache to 6 hours (aboone@redhat.com)

* Fri Dec 16 2011 Dan McPherson <dmcphers@redhat.com> 0.2.5-1
- some cleanup of server-common (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.4-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.2-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.1-1
- bump spec numbers (dmcphers@redhat.com)
- Adding cartridge list cache. Added nossh to validation for ssh key (BZ
  767442). Based on 2cbab9d374409 Added secondary ssh key management based on
  Ravi's work (kraman@gmail.com)
- Adding first version of app move admin utility (kraman@gmail.com)
- fix app not found cases (dmcphers@redhat.com)
- Added ability to add/remove/list secondary ssh keys Added admin tools
  (kraman@gmail.com)
- more consistent error handling (dmcphers@redhat.com)
- get jenkins running again (dmcphers@redhat.com)
- get create domain working (dmcphers@redhat.com)
- fix delete (dmcphers@redhat.com)
- merge code for deletion of namespace into cloud-sdk (rchopra@redhat.com)
- Merge remote-tracking branch 'origin/master' into mirage (kraman@gmail.com)
- Added application, cloud_user observers to validate objects and print jenkins
  related warnings. Added per application user delegation (with ssh keys)
  (kraman@gmail.com)

* Sun Dec 11 2011 Dan McPherson <dmcphers@redhat.com> 0.1.17-1
- building cloud sdk (dmcphers@redhat.com)
- Changed cdk-controller to be rails plugin. Modified express-broker with
  customizations and integrating cdk-controller (kraman@gmail.com)
- Checkpoint: Added cartridge populated env vars, broker key reuest and system
  ssh keys. (kraman@gmail.com)
- Checkpoint: cartridge and embedded actions work (kraman@gmail.com)
- observers containing express specific code for user and app creation
  (rchopra@redhat.com)
- Checkpoint cart_list_post working (kraman@gmail.com)
- Bug fixes in DNS service API Added ability to store users in data store API
  create/modify domain and user_info calls working. (kraman@gmail.com)
- Checkpoint of cloud-sdk work. Added implementation and bugfixes for
  Datastore, Auth and node-communication user-info works (kraman@gmail.com)
- move auth token logic (dmcphers@redhat.com)
- starting to fill in dnsservice (dmcphers@redhat.com)
- Flushed out data storage API CloudUser model close to complete Changed
  AuthAPI methods to be static (kraman@gmail.com)
- rpm work (dmcphers@redhat.com)
- Added auth service code. (kraman@gmail.com)
- Starting work on migration of common logic from broker into common +
  controller packages (kraman@gmail.com)
- change common files (dmcphers@redhat.com)
- Automatic commit of package [rubygem-cloud-sdk-controller] release
  [0.1.16-1]. (dmcphers@redhat.com)
- building updates (dmcphers@redhat.com)
- Automatic commit of package [rubygem-cloud-sdk-controller] release
  [0.1.15-1]. (dmcphers@redhat.com)
- engine -> node (dmcphers@redhat.com)
- more work splitting into 3 gems (dmcphers@redhat.com)
- split into three gems (dmcphers@redhat.com)

* Tue Nov 29 2011 Dan McPherson <dmcphers@redhat.com> 0.1.16-1
- building updates (dmcphers@redhat.com)

* Mon Nov 28 2011 Dan McPherson <dmcphers@redhat.com> 0.1.15-1
- new package built with tito


