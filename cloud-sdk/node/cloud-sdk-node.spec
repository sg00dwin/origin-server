%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname cloud-sdk-node
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        Cloud Development Node
Name:           rubygem-%{gemname}
Version:        0.5.5
Release:        1%{?dist}
Group:          Development/Languages
License:        ASL 2.0
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
Summary:        Cloud Development Node Library
Requires:       rubygem(%{gemname}) = %version
Provides:       ruby(%{gemname}) = %version

%description
This contains the Cloud Development Node packaged as a rubygem.

%description -n ruby-%{gemname}
This contains the Cloud Development Node packaged as a ruby site library.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}/cdk
mkdir -p %{buildroot}%{_sysconfdir}/cdk
mkdir -p %{buildroot}%{gemdir}
mkdir -p %{buildroot}%{ruby_sitelib}
mkdir -p %{_bindir}

ln -s %{geminstdir}/lib/cloud-sdk-node/express/setup_pam_fs_limits.sh %{buildroot}/%{_bindir}/setup_pam_fs_limits.sh

# Build and install into the rubygem structure
gem build %{gemname}.gemspec
gem install --local --install-dir %{buildroot}%{gemdir} --force %{gemname}-%{version}.gem

# Move the gem binaries to the standard filesystem location
mv %{buildroot}%{gemdir}/bin/* %{buildroot}%{_bindir}
rm -rf %{buildroot}%gemdir}/bin

# Move the gem configs to the standard filesystem location
mv %{buildroot}%{geminstdir}/conf/* %{buildroot}%{_sysconfdir}/cdk

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
%{_sysconfdir}/cdk
%{_bindir}/*

%files -n ruby-%{gemname}
%{ruby_sitelib}/%{gemname}
%{ruby_sitelib}/%{gemname}.rb

%changelog
* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.5.4-1
- Updating gem versions (dmcphers@redhat.com)

* Sat Feb 25 2012 Dan McPherson <dmcphers@redhat.com> 0.5.3-1
- Updating gem versions (dmcphers@redhat.com)
- Adds code to remove last access file when an app is destroyed.
  (mpatel@redhat.com)
- shellescape on cdk side too (rchopra@redhat.com)
- Update cartridge configure hooks to load git repo from remote URL Add REST
  API to create application from template Moved application template
  models/controller to cloud-sdk (kraman@gmail.com)
- run connectors as non-root (rchopra@redhat.com)
- include open4 for cdk-connector-execute, fix in php publish_http_url
  connector.. we dont need the external port for proxying web interfaces
  (rchopra@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- REST call to create a scalable app; fix in cdk-connector-execute; fix in
  app.scaleup function (rchopra@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.5.2-1
- Updating gem versions (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- checkpoint 4 - horizontal scaling bug fixes, multiple gears ok, scaling to be
  tested (rchopra@redhat.com)
- Merge branch 'TA1550' (jhonce@redhat.com)
- initial load of cdk-populate-repo (jhonce@redhat.com)
- merging changes (abhgupta@redhat.com)
- initial checkin for US1900 (abhgupta@redhat.com)
- checkpoint 2 - option to create scalable type of app, scaleup/scaledown apis
  added, group minimum requirements get fulfilled (rchopra@redhat.com)
- checkpoint 1 - horizontal scaling broker support (rchopra@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.5.1-1
- Updating gem versions (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.4.5-1
- Updating gem versions (dmcphers@redhat.com)
- cleaning up version reqs (dmcphers@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.4.4-1
- Updating gem versions (dmcphers@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Port proxy API
  calls." (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Make proxy remove
  clean up a port regardless of whether it was defined." (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Only remove ports
  which the user is allowed to use." (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Add proxy
  reconfiguration calls" (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Add cdk commands
  for proxy ports." (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Fix minor syntax
  errors." (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Wrong kind of
  quotes" (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Needed end of
  line" (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "Needed to convert
  port number to integer" (rmillner@redhat.com)
- Rolling back my changes to expose targetted proxy. Revert "For compat with
  abstract cartridge, prefix variables with OPENSHIFT" (rmillner@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.4.3-1
- Updating gem versions (dmcphers@redhat.com)
- cleaning up specs to force a build (dmcphers@redhat.com)

* Sat Feb 11 2012 Dan McPherson <dmcphers@redhat.com> 0.4.2-1
- Updating gem versions (dmcphers@redhat.com)
- cleanup specs (dmcphers@redhat.com)
- get move working again and add quota support (dmcphers@redhat.com)
- For compat with abstract cartridge, prefix variables with OPENSHIFT
  (rmillner@redhat.com)
- Needed to convert port number to integer (rmillner@redhat.com)
- Needed end of line (rmillner@redhat.com)
- Wrong kind of quotes (rmillner@redhat.com)
- Fix minor syntax errors. (rmillner@redhat.com)
- Add cdk commands for proxy ports. Use exceptions rather than bad exit codes.
  (rmillner@redhat.com)
- Add proxy reconfiguration calls (rmillner@redhat.com)
- Only remove ports which the user is allowed to use. (rmillner@redhat.com)
- Make proxy remove clean up a port regardless of whether it was defined.
  (rmillner@redhat.com)
- Port proxy API calls. (rmillner@redhat.com)
- Fixed env var delete on node Added logic to save app after critical steps on
  node suring create/destroy/configure/deconfigure Handle failures on
  start/stop of application or cartridge (kraman@gmail.com)
- fix node test cases (dmcphers@redhat.com)
- Fixes for re-enabling cli tools. git url is not yet working.
  (kraman@gmail.com)
- Updating models to improove schems of descriptor in mongo Moved
  connection_endpoint to broker (kraman@gmail.com)
- Creating models for descriptor Fixing manifest files Added command to list
  installed cartridges and get descriptors (kraman@gmail.com)
- change state machine dep (dmcphers@redhat.com)
- move the rest of the controller tests into broker (dmcphers@redhat.com)

