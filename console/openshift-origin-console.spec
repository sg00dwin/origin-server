%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname openshift-origin-console
%global gemversion %(echo %{version} | cut -d'.' -f1-3)
%global geminstdir %{gemdir}/gems/%{gemname}-%{gemversion}

%if 0%{?fedora}%{?rhel} <= 6
    %global scl ruby193
    %global scl_prefix ruby193-
%endif
%{!?scl:%global pkg_name %{name}}
%{?scl:%scl_package rubygem-%{gem_name}}
%global gem_name openshift-origin-console
%global rubyabi 1.9.1

Summary:        OpenShift Origin Management Console
Name:           rubygem-%{gemname}
Version:        0.0.1
Release:        1%{?dist}
Group:          Development/Languages
License:        ASL 2.0
URL:            https://openshift.redhat.com
Source0:        rubygem-%{gem_name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       %{?scl:%scl_prefix}ruby(abi) = %{rubyabi}
Requires:       %{?scl:%scl_prefix}ruby
Requires:       %{?scl:%scl_prefix}rubygems
Requires:       %{?scl:%scl_prefix}rubygem(bundler)

%if 0%{?fedora}%{?rhel} <= 6
BuildRequires:  ruby193-build
BuildRequires:  scl-utils-build
%endif

BuildRequires:  %{?scl:%scl_prefix}ruby(abi) = %{rubyabi}
BuildRequires:  %{?scl:%scl_prefix}ruby 
BuildRequires:  %{?scl:%scl_prefix}rubygems
BuildRequires:  %{?scl:%scl_prefix}rubygems-devel
BuildRequires:  %{?scl:%scl_prefix}rubygem(rake)
BuildRequires:  %{?scl:%scl_prefix}rubygem(bundler)

BuildArch:      noarch
Provides:       rubygem(%{gem_name}) = %version
%description
This contains the OpenShift Origin Management Console packaged as a rubygem.

%prep
%setup -q

%build
%{?scl:scl enable %scl - << \EOF}
mkdir -p .%{gem_dir}

# Temporary BEGIN
bundle install
# Temporary END
pushd test/rails_app/
RAILS_RELATIVE_URL_ROOT=/console bundle exec rake assets:precompile assets:public_pages
rm -rf tmp/cache/*
echo > log/production.log
popd

# Create the gem as gem install only works on a gem file
gem build %{gem_name}.gemspec

gem install -V \
        --local \
        --install-dir ./%{gem_dir} \
        --bindir ./%{_bindir} \
        --force \
        --rdoc \
        %{gem_name}-%{version}.gem
%{?scl:EOF}

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a ./%{gem_dir}/* %{buildroot}%{gem_dir}/

%clean
rm -rf %{buildroot}

%files
%{gem_instdir}
%{gem_cache}
%{gem_spec}
