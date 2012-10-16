%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname openshift-origin-dns-dynect
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        OpenShift plugin for Dynect DNS service
Name:           rubygem-%{gemname}
Version: 0.13.5
Release:        1%{?dist}
Group:          Development/Languages
License:        ASL 2.0
URL:            http://openshift.redhat.com
Source0:        rubygem-%{gemname}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Obsoletes: rubygem-uplift-dynect-plugin

Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(openshift-origin-common)
Requires:       rubygem(json)

BuildRequires:  ruby
BuildRequires:  rubygems
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %version

%package -n ruby-%{gemname}
Summary:        OpenShift plugin for Dynect DNS service
Requires:       rubygem(%{gemname}) = %version
Provides:       ruby(%{gemname}) = %version

%description
Provides a DYN DNS service based plugin

%description -n ruby-%{gemname}
Provides a DYN DNS service based plugin

%prep
%setup -q

%build

%post
echo " The openshift-origin-dns-dynect requires the following config entries to be present:"
echo " * dns[:dynect_url]            - The dynect API url"
echo " * dns[:dynect_user_name]      - The API user"
echo " * dns[:dynect_password]       - The API user password"
echo " * dns[:dynect_customer_name]  - The API customer name"
echo " * dns[:zone]                  - The DNS Zone"
echo " * dns[:domain_suffix]         - The domain suffix for applications"

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
* Tue Oct 16 2012 Adam Miller <admiller@redhat.com> 0.13.5-1
- Fix dynect plugin: raise DNS already exists exception instead of error
  communicating with DNS when dynect error code is TARGET_EXISTS
  (rpenta@redhat.com)

* Mon Oct 08 2012 Dan McPherson <dmcphers@redhat.com> 0.13.4-1
- Fixing renames, paths, configs and cleaning up old packages. Adding
  obsoletes. (kraman@gmail.com)

* Thu Oct 04 2012 Krishna Raman <kraman@gmail.com> 0.13.3-1
- new package built with tito

* Wed Oct 03 2012 Adam Miller <admiller@redhat.com> 0.13.2-1
- fix typos (dmcphers@redhat.com)

* Wed Aug 22 2012 Adam Miller <admiller@redhat.com> 0.13.1-1
- bump_minor_versions for sprint 17 (admiller@redhat.com)

* Thu Aug 16 2012 Adam Miller <admiller@redhat.com> 0.12.2-1
- Bug 848419 (dmcphers@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.12.1-1
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Tue Jul 10 2012 Adam Miller <admiller@redhat.com> 0.11.4-1
- Add modify application dns and use where applicable (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.11.3-1
- cleaning up specs (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.11.2-1
- new package built with tito

