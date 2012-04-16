%global drupal_release      6
%global drupal_base         %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all    %{drupal_base}/sites/all        
%global drupal_modules      %{drupal_sites_all}/modules/custom
%global modname             custom_forms

Name:    drupal%{drupal_release}-openshift-%{modname}
Version: 1.2
Release: 1%{?dist}
Summary: Openshift Red Hat Custom Forms for Drupal6
Group:   Applications/Publishing
License: GPLv2+
Source0: %{modname}-%{drupal_release}.x-%{version}.tar.gz
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:  drupal6

%description
Summary: Openshift Red Hat Custom Forms for Drupal6


%prep
%setup -qn %{modname}
# Remove empty index.html and others
find -size 0 | xargs rm -f

%build


%install
rm -rf $RPM_BUILD_ROOT
%{__mkdir} -p $RPM_BUILD_ROOT/%{drupal_modules}/%{modname}
cp -pr . $RPM_BUILD_ROOT/%{drupal_modules}/%{modname}


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{drupal_modules}/%{modname}

%changelog
* Mon Apr 16 2012 Dan McPherson <dmcphers@redhat.com> 1.2-1
- new package built with tito

* Mon Mar 5 2012 Anderson Silva <ansilva@redhat.com> - 1.0-1
- Initial rpm package
