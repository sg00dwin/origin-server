%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname openshift_origin_console
%global gemversion %(echo %{version} | cut -d'.' -f1-3)
%global geminstdir %{gemdir}/gems/%{gemname}-%{gemversion}

Summary:        OpenShift Origin Management Console
Name:           rubygem-%{gemname}
Version:        0.0.2
Release:        1%{?dist}
Group:          Development/Languages
License:        ASL 2.0
URL:            https://openshift.redhat.com
Source0:        rubygem-%{gemname}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(rails)
Requires:       rubygem(mocha)

BuildRequires:  ruby
BuildRequires:  rubygems
BuildRequires:  rubygem(rake)
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %version

%package -n ruby-%{gemname}
Summary:        OpenShift Origin Management Console
Requires:       rubygem(%{gemname}) = %version
Provides:       ruby(%{gemname}) = %version

%description
This contains the OpenShift Origin Management Console packaged as a rubygem.

%description -n ruby-%{gemname}
This contains the OpenShift Origin Management Console packaged as a ruby site library.

%prep
%setup -q
pwd
rake --trace version["%{version}"]

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
mkdir -p %{buildroot}%{ruby_sitelib}

# Build and install into the rubygem structure
gem build %{gemname}.gemspec
gem install --local --install-dir %{buildroot}%{gemdir} --force %{gemname}-%{gemversion}.gem

# Symlink into the ruby site library directories
ln -s %{geminstdir}/lib/%{gemname} %{buildroot}%{ruby_sitelib}
ln -s %{geminstdir}/lib/%{gemname}.rb %{buildroot}%{ruby_sitelib}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%dir %{geminstdir}
%doc %{geminstdir}/Gemfile
%{gemdir}/doc/%{gemname}-%{gemversion}
%{gemdir}/gems/%{gemname}-%{gemversion}
%{gemdir}/cache/%{gemname}-%{gemversion}.gem
%{gemdir}/specifications/%{gemname}-%{gemversion}.gemspec

%files -n ruby-%{gemname}
%{ruby_sitelib}/%{gemname}
%{ruby_sitelib}/%{gemname}.rb

%changelog
* Tue Aug 28 2012 Clayton Coleman <ccoleman@redhat.com> 0.0.2-1
- Ruby 1.9 removes #id on Object, to_key must be properly implemented.  Also
  make the passthrough object show as unpersisted. (ccoleman@redhat.com)
- Add gemfile flags for test-unit on 1.9 ruby (ccoleman@redhat.com)
- Ruby 1.9 compat (ccoleman@redhat.com)
- Ensure version can be run without bundler. (ccoleman@redhat.com)

* Mon Aug 27 2012 Clayton Coleman <ccoleman@redhat.com> 0.0.1-1
- new package built with tito

