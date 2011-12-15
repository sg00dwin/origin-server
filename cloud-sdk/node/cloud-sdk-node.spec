%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname cloud-sdk-node
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        Cloud Development Node
Name:           rubygem-%{gemname}
Version:        0.2.2
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
* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.2-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.2.1-1
- bump spec numbers (dmcphers@redhat.com)
- rhc-admin-move completed (kraman@gmail.com)
- get jenkins running again (dmcphers@redhat.com)

* Sun Dec 11 2011 Dan McPherson <dmcphers@redhat.com> 0.1.17-1
- building cloud sdk (dmcphers@redhat.com)
- Checkpoint: cartridge and embedded actions work (kraman@gmail.com)
- rpm work (dmcphers@redhat.com)
- Automatic commit of package [rubygem-cloud-sdk-node] release [0.1.16-1].
  (dmcphers@redhat.com)
- building updates (dmcphers@redhat.com)
- Automatic commit of package [rubygem-cloud-sdk-node] release [0.1.15-1].
  (dmcphers@redhat.com)
- engine -> node (dmcphers@redhat.com)

* Tue Nov 29 2011 Dan McPherson <dmcphers@redhat.com> 0.1.16-1
- building updates (dmcphers@redhat.com)

* Mon Nov 28 2011 Dan McPherson <dmcphers@redhat.com> 0.1.15-1
- new package built with tito

