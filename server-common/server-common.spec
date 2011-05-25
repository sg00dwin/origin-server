%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Common dependencies of the OpenShift broker and site
Name:          rhc-server-common
Version:       0.72.1
Release:       3%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-server-common-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: ruby
Requires:      ruby >= 1.8.7
Requires:      rubygem-parseconfig
Requires:      rubygem-json

BuildArch: noarch

%description
Provides the common dependencies for the OpenShift broker and site

%prep
%setup -q

%build
for f in openshift/**/*.rb
do
  ruby -c $f
done

%install
rm -rf %{buildroot}
SITE_LIB_DIR=$RPM_BUILD_ROOT/%{ruby_sitelibdir}
mkdir -p %{buildroot}%{ruby_sitelibdir}
cp -r openshift %{buildroot}%{ruby_sitelibdir}
cp openshift.rb %{buildroot}%{ruby_sitelibdir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{ruby_sitelibdir}/openshift
%{ruby_sitelibdir}/openshift.rb

%changelog
* Wed May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-3
- Fixing ruby build requirement

* Wed May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Fixing ruby version

* Wed May 25 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial refactoring
