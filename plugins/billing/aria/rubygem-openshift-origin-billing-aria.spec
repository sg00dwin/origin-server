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
Version: 1.4.0
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
* Wed Mar 06 2013 Adam Miller <admiller@redhat.com> 1.3.7-1
- Usage migration: show total #usage records created in the end
  (rpenta@redhat.com)

* Tue Mar 05 2013 Adam Miller <admiller@redhat.com> 1.3.6-1
- Migrate script: Add 'begin' usage records for all existing apps.
  (rpenta@redhat.com)

* Mon Mar 04 2013 Adam Miller <admiller@redhat.com> 1.3.5-1
- Aria plugin fixes (rpenta@redhat.com)

* Thu Feb 28 2013 Adam Miller <admiller@redhat.com> 1.3.4-1
- Fixing tags from merge of new package

* Wed Feb 27 2013 Ravi Sankar <rpenta@redhat.com> 1.3.3-1
- Re-organize aria plugin files (rpenta@redhat.com)
- Automatic commit of package [rubygem-openshift-origin-billing-aria] release
  [1.3.2-1]. (rpenta@redhat.com)
- More than 80%% of the code is rewritten to improve rhc-admin-ctl-usage script
  Added bulk_record_usage to billing api. Used light weight Moped session
  instead of Mongoid model for read/write to mongo. Leverages
  bulk_record_usage() aria api to report usage in bulk that reduces #calls to
  aria. Query cloud_users collection for billing account# instead of aria api
  (mongo op is cheaper than external aria api). Process users by 'login'
  (created index on this field in UsageRecord model) and cache user->billing
  account# After some experimentation, setting chunk size for bulk_record_usage
  as 30 (conservative). We can go upto 50, anything above 50 records we may run
  into URL too long error. Set/Unset sync_time in one mongo call. If
  bulk_record_usage fails, we don't know which records has failed and so we
  can't unset sync_time. This should happen rarely and if it happens, try
  processing the records again one at a time. Added option 'enable-logger' to
  log errors and warning to /var/broker/openshift/usage.log file which helps
  during investigation in prod environment. Handle incorrect records that can
  ariase due to some hidden bug in broker. Try to fix the records or delete the
  records that are no longer needed. Fix and add ctl_usage test cases Use
  account# in record_usage/bulk_record_usage, we don't need to compute billing
  user id. Make list/sync/remove-sync-lock to be used in conjunction. For users
  with no aria a/c, sync option will delete ended records from usage_records
  collection. Check usage and usage_record collection consistency only during
  usage record deletion. Handle exceptions gracefully. Enable usage tracking in
  production mode. (rpenta@redhat.com)

* Wed Feb 27 2013 Ravi Sankar <rpenta@redhat.com> 1.3.2-1
- new package built with tito

