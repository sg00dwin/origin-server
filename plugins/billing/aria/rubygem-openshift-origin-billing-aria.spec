%if 0%{?fedora}%{?rhel} <= 6
    %global scl ruby193
    %global scl_prefix ruby193-
%endif
%{!?scl:%global pkg_name %{name}}
%{?scl:%scl_package rubygem-%{gem_name}}
%global gem_name openshift-origin-billing-aria
%global rubyabi 1.9.1

Summary:        OpenShift plugin for Aria Billing service

Name:           rubygem-%{gem_name}
Version: 1.12.1
Release:        1%{?dist}
Group:          Development/Languages
License:        ASL 2.0
URL:            http://openshift.redhat.com
Source0:        rubygem-%{gem_name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       %{?scl:%scl_prefix}ruby(abi) = %{rubyabi}
Requires:       %{?scl:%scl_prefix}ruby
Requires:       %{?scl:%scl_prefix}rubygems
Requires:       rubygem(openshift-origin-common)
Requires:       %{?scl:%scl_prefix}rubygem(json)

%if 0%{?fedora}%{?rhel} <= 6
BuildRequires:  ruby193-build
BuildRequires:  scl-utils-build
%endif
BuildRequires:  %{?scl:%scl_prefix}ruby(abi) = %{rubyabi}
BuildRequires:  %{?scl:%scl_prefix}ruby 
BuildRequires:  %{?scl:%scl_prefix}rubygems
BuildRequires:  %{?scl:%scl_prefix}rubygems-devel
BuildArch:      noarch
Provides:       rubygem(%{gem_name}) = %version

%description
Provides Aria Billing service based plugin

%prep
%setup -q

%build
%{?scl:scl enable %scl - << \EOF}
mkdir -p ./%{gem_dir}
# Create the gem as gem install only works on a gem file
gem build %{gem_name}.gemspec
export CONFIGURE_ARGS="--with-cflags='%{optflags}'"
# gem install compiles any C extensions and installs into a directory
# We set that to be a local directory so that we can move it into the
# buildroot in %%install
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

mkdir -p %{buildroot}/etc/openshift/plugins.d
cp conf/openshift-origin-billing-aria.conf %{buildroot}/etc/openshift/plugins.d/
cp conf/openshift-origin-billing-aria-dev.conf %{buildroot}/etc/openshift/plugins.d/

%clean
rm -rf %{buildroot}                                

%files
%defattr(-,root,root,-)
%doc %{gem_docdir}
%{gem_instdir}
%{gem_spec}
%{gem_cache}
%config(noreplace) /etc/openshift/plugins.d/openshift-origin-billing-aria.conf
/etc/openshift/plugins.d/openshift-origin-billing-aria-dev.conf

%changelog
* Thu Aug 29 2013 Adam Miller <admiller@redhat.com> 1.12.1-1
- nurture -> analytics (dmcphers@redhat.com)
- bump_minor_versions for sprint 33 (admiller@redhat.com)
- Improve broker payment failure message (jliggitt@redhat.com)

* Tue Aug 20 2013 Adam Miller <admiller@redhat.com> 1.11.3-1
- Merge pull request #1834 from pravisankar/dev/ravi/fix-sending-entitlements
  (dmcphers+openshiftbot@redhat.com)
- Skip sending support entitlement email notices for dunning-{1..4} to active
  aria events. (rpenta@redhat.com)

* Mon Aug 19 2013 Adam Miller <admiller@redhat.com> 1.11.2-1
- <cartridge versions> Bug 997864, fix up references to renamed carts
  https://trello.com/c/evcTYKdn/219-3-adjust-out-of-date-cartridge-versions
  (jolamb@redhat.com)

* Thu Aug 08 2013 Adam Miller <admiller@redhat.com> 1.11.1-1
- Bug 989642 - Strip nil entries during usage sync (rpenta@redhat.com)
- bump_minor_versions for sprint 32 (admiller@redhat.com)

* Tue Jul 30 2013 Adam Miller <admiller@redhat.com> 1.10.4-1
- Bug 988697 - Fix billing events controller. (rpenta@redhat.com)

