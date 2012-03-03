%define ruby_sitelibdir            %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")

Summary:       Common dependencies of the OpenShift broker and site
Name:          rhc-server-common
Version:       0.87.0
Release:       1%{?dist}
Group:         Network/Daemons
License:       GPLv2
URL:           http://openshift.redhat.com
Source0:       rhc-server-common-%{version}.tar.gz

BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: ruby
Requires:      ruby >= 1.8.7
Requires:      rubygem-parseconfig
Requires:      rubygem-json
Requires:      rubygem-aws-sdk
Requires:      rhc-common

Obsoletes:     rubygem-aws

BuildArch: noarch

%description
Provides the common dependencies for the OpenShift broker and site

%prep
%setup -q

%build
for f in openshift/*.rb
do
  ruby -c $f
done

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{ruby_sitelibdir}
cp -r openshift %{buildroot}%{ruby_sitelibdir}
cp openshift.rb %{buildroot}%{ruby_sitelibdir}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{ruby_sitelibdir}/openshift
%{ruby_sitelibdir}/openshift.rb

%pre
/usr/sbin/useradd libra_passenger -g libra_user \
                                  -d /var/lib/passenger \
                                  -r \
                                  -s /sbin/nologin 2>&1 > /dev/null || :

%changelog
* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.86.2-1
- Adding mysql because of some cartridge bugs (mmcgrath@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.86.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- cleanup (dmcphers@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- bump spec numbers (dmcphers@redhat.com)
