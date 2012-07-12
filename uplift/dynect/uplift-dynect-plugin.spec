%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname uplift-dynect-plugin
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        Uplift plugin for Dynect DNS service
Name:           rubygem-%{gemname}
Version: 0.12.0
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
Summary:        Uplift plugin for Dynect DNS service
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
echo " The uplift-dynect-plugin requires the following config entries to be present:"
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
* Tue Jul 10 2012 Adam Miller <admiller@redhat.com> 0.11.4-1
- Add modify application dns and use where applicable (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.11.3-1
- cleaning up specs (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.11.2-1
- new package built with tito

