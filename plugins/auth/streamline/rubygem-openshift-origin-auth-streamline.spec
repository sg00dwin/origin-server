%if 0%{?fedora}%{?rhel} <= 6
    %global scl ruby193
    %global scl_prefix ruby193-
%endif
%{!?scl:%global pkg_name %{name}}
%{?scl:%scl_package rubygem-%{gem_name}}
%global gem_name openshift-origin-auth-streamline
%global rubyabi 1.9.1

Summary:        OpenShift plugin for streamline auth service
Name:           rubygem-%{gem_name}
Version: 1.8.2
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
Obsoletes: rubygem-swingshift-streamline-plugin

%description
Provides a streamline auth service based plugin

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

%post

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a ./%{gem_dir}/* %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}/etc/openshift/plugins.d
cp %{buildroot}/%{gem_instdir}/conf/openshift-origin-auth-streamline.conf %{buildroot}/etc/openshift/plugins.d/
cp %{buildroot}/%{gem_instdir}/conf/openshift-origin-auth-streamline-dev.conf %{buildroot}/etc/openshift/plugins.d/

%clean
rm -rf %{buildroot}                                

%files
%defattr(-,root,root,-)
%doc %{gem_docdir}
%{gem_instdir}
%{gem_spec}
%{gem_cache}
%config(noreplace) /etc/openshift/plugins.d/openshift-origin-auth-streamline.conf
/etc/openshift/plugins.d/openshift-origin-auth-streamline-dev.conf

%changelog
* Wed Aug 21 2013 Adam Miller <admiller@redhat.com> 1.8.2-1
- Merge pull request #1835 from lnader/master
  (dmcphers+openshiftbot@redhat.com)
- Bug 865183 (lnader@redhat.com)
- Bug 998982 - improve msg exposed in rhc when user hasnt accepted terms
  (jforrest@redhat.com)

* Fri Jul 12 2013 Adam Miller <admiller@redhat.com> 1.8.1-1
- bump_minor_versions for sprint 31 (admiller@redhat.com)

* Tue Jul 02 2013 Adam Miller <admiller@redhat.com> 1.7.2-1
- Added rhc-admin-delete-subaccounts script: Deletes subaccounts that has no
  activity for at least one week and has no apps for the given parent login.
  (rpenta@redhat.com)

* Tue Jun 25 2013 Adam Miller <admiller@redhat.com> 1.7.1-1
- bump_minor_versions for sprint 30 (admiller@redhat.com)

* Fri Jun 21 2013 Adam Miller <admiller@redhat.com> 1.6.2-1
- Mark ticket as ignored (ccoleman@redhat.com)
- Bug 975556 - Pass noticket=true to Streamline to avoid creating a ticket
  (ccoleman@redhat.com)

* Thu Apr 25 2013 Adam Miller <admiller@redhat.com> 1.6.1-1
- bump_minor_versions for sprint XX (tdawson@redhat.com)

* Mon Apr 08 2013 Adam Miller <admiller@redhat.com> 1.5.2-1
- Billing entitlement email notification changes:  - Don't capture all events
  from aria  - Plan change (upgrade/downgrade) will send revoke/assign
  entitlement email without depending on aria events.  - Only handle aria
  events in case of account status changes due to dunning or account
  supplemental field changes.  - Don't send revoke/assign entitlements if the
  modified plan is free plan.  - Fetch account contact address by querying
  streamline  - Don't use 'RHLogin' supplemental field for login, instead query
  mongo with aria acct_no to fetch login.    Reason: Any special chars in
  RHLogin is not properly escaped by aria.  - Bug fixes  - Cleanup
  (rpenta@redhat.com)

* Thu Mar 28 2013 Adam Miller <admiller@redhat.com> 1.5.1-1
- bump_minor_versions for sprint 26 (admiller@redhat.com)

* Mon Mar 18 2013 Adam Miller <admiller@redhat.com> 1.4.2-1
- Fix for bug 921713 now passing correct number of arguments to
  Rails.logger.error method (abhgupta@redhat.com)

* Thu Mar 07 2013 Adam Miller <admiller@redhat.com> 1.4.1-1
- bump_minor_versions for sprint 25 (admiller@redhat.com)

* Wed Mar 06 2013 Adam Miller <admiller@redhat.com> 1.3.4-1
- Remove test case (ccoleman@redhat.com)
- Bug 888384 - Stop caching rh_sso (ccoleman@redhat.com)

* Tue Feb 26 2013 Adam Miller <admiller@redhat.com> 1.3.3-1
- Merge remote-tracking branch 'origin/master' into session_auth_support_2
  (ccoleman@redhat.com)
- Merge branch 'isolate_api_behavior_from_base_controller' into
  session_auth_support_2 (ccoleman@redhat.com)
- In test mode streamline should use default settings with INTEGRATED=false,
  other code errors (ccoleman@redhat.com)
- Changes to the broker to match session auth support in the origin
  (ccoleman@redhat.com)

* Fri Feb 08 2013 Adam Miller <admiller@redhat.com> 1.3.2-1
- Merge remote-tracking branch 'origin/master' into
  isolate_api_behavior_from_base_controller (ccoleman@redhat.com)
- Remove legacy login() method on authservice (ccoleman@redhat.com)

* Thu Feb 07 2013 Adam Miller <admiller@redhat.com> 1.3.1-1
- bump_minor_versions for sprint 24 (admiller@redhat.com)

* Tue Jan 29 2013 Adam Miller <admiller@redhat.com> 1.2.3-1
- when changing variable names, change them all (admiller@redhat.com)
- Don't use streamline auth service for rails test env (rpenta@redhat.com)

* Tue Jan 29 2013 Adam Miller <admiller@redhat.com>
- Don't use streamline auth service for rails test env (rpenta@redhat.com)

* Sat Nov 17 2012 Adam Miller <admiller@redhat.com> 1.2.1-1
- bump_minor_versions for sprint 21 (admiller@redhat.com)

* Wed Nov 14 2012 Adam Miller <admiller@redhat.com> 1.1.2-1
- Fixing gemspecs (kraman@gmail.com)
- Moving plugins to Rails 3.2.8 engines (kraman@gmail.com)
- sclizing gems (dmcphers@redhat.com)

* Thu Nov 08 2012 Adam Miller <admiller@redhat.com> 1.1.1-1
- Bumping specs to at least 1.1 (dmcphers@redhat.com)

* Tue Oct 30 2012 Adam Miller <admiller@redhat.com> 1.0.1-1
- bumping specs to at least 1.0.0 (dmcphers@redhat.com)

