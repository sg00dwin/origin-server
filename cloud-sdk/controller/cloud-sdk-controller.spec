%define controllerdir %{_localstatedir}/www/cloud-sdk-controller

Summary:        Cloud Development Controller
Name:           rubygem-cloud-sdk-controller
Version:        0.1.16
Release:        1%{?dist}
Group:          Development/Languages
License:        AGPLv3
URL:            http://openshift.redhat.com
Source0:        rubygem-cloud-sdk-controller-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       ruby(abi) = 1.8
Requires:       rubygems
Requires:       rubygem(activemodel)
Requires:       rubygem(highline)
Requires:       rubygem(json_pure)
Requires:       rubygem(mocha)
Requires:       rubygem(parseconfig)
Requires:       rubygem(state_machine)
Requires:       rubygem(cloud-sdk-common)
Requires:       httpd
Requires:       mod_ssl
Requires:       mod_passenger
Requires:       rubygem-passenger-native-libs
Requires:       rubygem-rails
Requires:       rubygem-xml-simple

BuildRequires:  ruby
BuildRequires:  rubygems
BuildArch:      noarch

%description
This contains the Cloud Development Controller.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{controllerdir}
cp -r . %{buildroot}%{controllerdir}

mkdir -p %{buildroot}%{controllerdir}/run
mkdir -p %{buildroot}%{controllerdir}/log
touch %{buildroot}%{controllerdir}/log/production.log

%clean
rm -rf %{buildroot}                           

%files
%defattr(0640,root,libra_user,0750)
%attr(0666,-,-) %{controllerdir}/log/production.log
%config(noreplace) %{controllerdir}/config/environments/production.rb
#%config(noreplace) %{controllerdir}/config/keys/public.pem
#%config(noreplace) %{controllerdir}/config/keys/private.pem
#%attr(0600,-,-) %config(noreplace) %{controllerdir}/config/keys/rsync_id_rsa
#%config(noreplace) %{controllerdir}/config/keys/rsync_id_rsa.pub
#%attr(0750,-,-) %{controllerdir}/config/keys/generate_rsa_keys
#%attr(0750,-,-) %{controllerdir}/config/keys/generate_rsync_rsa_keys
%attr(0750,-,-) %{controllerdir}/script
%{controllerdir}

%changelog
* Tue Nov 29 2011 Dan McPherson <dmcphers@redhat.com> 0.1.16-1
- building updates (dmcphers@redhat.com)

* Mon Nov 28 2011 Dan McPherson <dmcphers@redhat.com> 0.1.15-1
- new package built with tito


