%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname openshift-origin-auth-streamline
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:        OpenShift Origin plugin for streamline auth service
Name:           rubygem-%{gemname}
Version: 1.1.0
Release:        1%{?dist}
Group:          Development/Languages
License:        ASL 2.0
URL:            http://openshift.redhat.com
Source0:        rubygem-%{gemname}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Obsoletes: rubygem-swingshift-streamline-plugin

Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(openshift-origin-common)
Requires:       rubygem(json)

BuildRequires:  ruby
BuildRequires:  rubygems
BuildArch:      noarch
Provides:       rubygem(%{gemname}) = %version

%package -n ruby-%{gemname}
Summary:        OpenShift Origin plugin for streamline auth service
Requires:       rubygem(%{gemname}) = %version
Provides:       ruby(%{gemname}) = %version

%description
Provides a streamline auth service based plugin

%description -n ruby-%{gemname}
Provides a streamline auth service based plugin

%prep
%setup -q

%build

%post

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

mkdir -p %{buildroot}/etc/openshift/plugins.d
cp %{buildroot}/%{geminstdir}/conf/openshift-origin-auth-streamline.conf %{buildroot}/etc/openshift/plugins.d/
cp %{buildroot}/%{geminstdir}/conf/openshift-origin-auth-streamline-dev.conf %{buildroot}/etc/openshift/plugins.d/

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
%config(noreplace) /etc/openshift/plugins.d/openshift-origin-auth-streamline.conf
/etc/openshift/plugins.d/openshift-origin-auth-streamline-dev.conf
%files -n ruby-%{gemname}
%{ruby_sitelib}/%{gemname}
%{ruby_sitelib}/%{gemname}.rb

%changelog
* Tue Oct 30 2012 Adam Miller <admiller@redhat.com> 1.0.1-1
- bumping specs to at least 1.0.0 (dmcphers@redhat.com)

* Mon Oct 29 2012 Adam Miller <admiller@redhat.com> 0.13.6-1
- Converted dynect and streamline plugins to rails engines Moved plugin config
  into /etc/openshift/plugins.d Moved broker global conf to
  /etc/openshift/broker.conf Modified broker and plugins to loca *-dev.conf
  files when in development environment Mofied broker to switch to dev
  environment with /etc/openshift/development flag is present
  (kraman@gmail.com)

* Mon Oct 15 2012 Adam Miller <admiller@redhat.com> 0.13.5-1
- Fix streamline obsoletes (pmorie@gmail.com)

* Mon Oct 08 2012 Adam Miller <admiller@redhat.com> 0.13.4-1
- Merge pull request #455 from brenton/streamline_auth_misc1-rebase
  (openshift+bot@redhat.com)
- Refactorings needed to share the generate_broker_key logic with Origin
  (bleanhar@redhat.com)

* Mon Oct 08 2012 Dan McPherson <dmcphers@redhat.com> 0.13.3-1
- Fixing renames, paths, configs and cleaning up old packages. Adding
  obsoletes. (kraman@gmail.com)

* Thu Oct 04 2012 Krishna Raman <kraman@gmail.com> 0.13.2-1
- new package built with tito

* Wed Aug 22 2012 Adam Miller <admiller@redhat.com> 0.13.1-1
- bump_minor_versions for sprint 17 (admiller@redhat.com)

* Tue Aug 14 2012 Adam Miller <admiller@redhat.com> 0.12.2-1
- capturing broker key/iv auth failure and returning access denied exception
  (abhgupta@redhat.com)
- fixing auth issue that returned 500 if credentials were not specified in the
  new rest api (abhgupta@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.12.1-1
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.11.3-1
- cleaning up specs (dmcphers@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.11.2-1
- new package built with tito
