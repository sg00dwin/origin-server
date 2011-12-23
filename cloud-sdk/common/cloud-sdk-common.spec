%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname cloud-sdk-common
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        Cloud Development Common
Name:           rubygem-%{gemname}
Version:        0.2.7
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

BuildRequires:  ruby
BuildRequires:  rubygems
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %version

%package -n ruby-%{gemname}
Summary:        Cloud Development Common Library
Requires:       rubygem(%{gemname}) = %version
Provides:       ruby(%{gemname}) = %version

%description
This contains the Cloud Development Common packaged as a rubygem.

%description -n ruby-%{gemname}
This contains the Cloud Development Common packaged as a ruby site library.

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
* Fri Dec 23 2011 Dan McPherson <dmcphers@redhat.com> 0.2.7-1
- Bug 770085 (dmcphers@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.2.6-1
- removing more of server-common (dmcphers@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.2.5-1
- Bug 769716 (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.4-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.1-1
- bump spec numbers (dmcphers@redhat.com)
- more consistent error handling (dmcphers@redhat.com)
- fix delete (dmcphers@redhat.com)

* Sun Dec 11 2011 Dan McPherson <dmcphers@redhat.com> 0.1.17-1
- Changed cdk-controller to be rails plugin. Modified express-broker with
  customizations and integrating cdk-controller (kraman@gmail.com)
- Checkpoint: cartridge and embedded actions work (kraman@gmail.com)
- Bug fixes in DNS service API Added ability to store users in data store API
  create/modify domain and user_info calls working. (kraman@gmail.com)
- Checkpoint of cloud-sdk work. Added implementation and bugfixes for
  Datastore, Auth and node-communication user-info works (kraman@gmail.com)
- Flushed out data storage API CloudUser model close to complete Changed
  AuthAPI methods to be static (kraman@gmail.com)
- rpm work (dmcphers@redhat.com)
- Starting work on migration of common logic from broker into common +
  controller packages (kraman@gmail.com)
- Automatic commit of package [rubygem-cloud-sdk-common] release [0.1.16-1].
  (dmcphers@redhat.com)
- building updates (dmcphers@redhat.com)
- Automatic commit of package [rubygem-cloud-sdk-common] release [0.1.15-1].
  (dmcphers@redhat.com)
- engine -> node (dmcphers@redhat.com)
- more work splitting into 3 gems (dmcphers@redhat.com)
- split into three gems (dmcphers@redhat.com)

* Tue Nov 29 2011 Dan McPherson <dmcphers@redhat.com> 0.1.16-1
- building updates (dmcphers@redhat.com)

* Mon Nov 28 2011 Dan McPherson <dmcphers@redhat.com> 0.1.15-1
- new package built with tito


