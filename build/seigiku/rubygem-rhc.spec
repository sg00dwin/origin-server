%global ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%global gemname rhc
%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary:       OpenShift Client Tools
Name:          rubygem-%{gemname}
Version:       0.84.1
Release:       1%{?dist}
Group:         Development/Tools
License:       MIT
URL:           https://openshift.redhat.com/app/express
Source0:       http://rubygems.org/downloads/%{gemname}-%{version}.gem
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:      ruby(abi) = 1.8
Requires:      rubygems
Requires:      rubygem-json_pure
Requires:      rubygem-parseconfig
BuildRequires: rubygems, rubygem-rake
BuildArch:     noarch
Provides:      rubygem(%{gemname}) = %{version}

%description
OpenShift Client Tools allows you to create and deploy applications to
the cloud. The OpenShift client is a command line tool that allows you
to manage your applications in the cloud.

%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
mkdir -p %{buildroot}%{_bindir}
gem install --local --install-dir %{buildroot}%{gemdir} \
            --force --rdoc %{SOURCE0}
chmod 0755 %{buildroot}%{gemdir}/bin/*
chmod 0755 %{buildroot}%{geminstdir}/bin/*

mv %{buildroot}%{gemdir}/bin/* %{buildroot}%{_bindir}/

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%dir %{geminstdir}
%dir %{geminstdir}/bin
%dir %{geminstdir}/lib
%dir %{geminstdir}/conf
%doc %{gemdir}/doc/%{gemname}-%{version}
%doc %{geminstdir}/LICENSE
%doc %{geminstdir}/README
%doc %{geminstdir}/Rakefile
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec
%{geminstdir}/bin/*
%{geminstdir}/lib/*
%{geminstdir}/conf/*
%{_bindir}/*

%changelog
* Wed Dec 21 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.83.9-1
- Update to version 0.83.9 

* Thu Dec 15 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.82.18-1
- Update to version 0.82.18

* Thu Dec 01 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.81.14-2
- Requires fixed to json_pure

* Tue Nov 15 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.81.14-1
- Update to version 0.81.14

* Wed Nov 02 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.80.5-1
- Update to version 0.80.5

* Wed Oct 19 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.79.5-1
- Update to version 0.79.5

* Tue Aug 23 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.75.9-1
- Update to version 0.75.9

* Tue Aug 02 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.73.14-1
- Update to version 0.73.14

* Sat Jul 09 2011 Guillermo Gómez <gomix@fedoraproject.org - 0.71.2-2
- Package now owns geminstdir
- User binaries moved to the right place
- %%dir missuse corrected
- Better URL
- Licenced fixed to MIT

* Thu Jun 23 2011 Guillermo Gómez <gomix@fedoraproject.org> - 0.71.2-1
- Initial package
