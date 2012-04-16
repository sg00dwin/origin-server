%global drupal_release      6
%global drupal_base         %{_datadir}/drupal%{drupal_release}
%global drupal_sites_all    %{drupal_base}/sites/all        
%global drupal_themedir     %{drupal_sites_all}/themes
%global drupal_themename    openshift-theme

Name:           drupal6-%{drupal_themename}
Version:        3.0.1
Release:        1%{?dist}
Summary:        Red Hat Openshift theme for Drupal %{drupal_release}

Group:          Applications/Publishing
License:        GPLv2+ and GPL+ or MIT
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       drupal6

%description
Red Hat Openshift Drupal Theme

%prep
%setup -q
# Remove empty index.html and others
find -size 0 | xargs rm -f


%build


%install
rm -rf $RPM_BUILD_ROOT
%{__mkdir} -p $RPM_BUILD_ROOT/%{drupal_themedir}/%{drupal_themename} 
cp -pr . $RPM_BUILD_ROOT/%{drupal_themedir}/%{drupal_themename}


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{drupal_themedir}/%{drupal_themename}


%changelog
* Tue Apr 16 2012 Anderson Silva <ansilva@redhat.com> - 3.0.1-1
- update version

* Tue Mar 20 2012 Anderson Silva <ansilva@redhat.com> - 3.0-1
- Openshif new theme 

* Wed Mar 14 2012 Anderson Silva <ansilva@redhat.com> - 2.0-2
- Rename RPM for consistency

* Wed Mar 5 2012 Anderson Silva <ansilva@redhat.com> - 2.0-1
- Fix requirements
