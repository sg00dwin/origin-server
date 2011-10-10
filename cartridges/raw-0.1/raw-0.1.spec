%define cartridgedir %{_libexecdir}/li/cartridges/raw-0.1

Summary:   Provides raw support
Name:      rhc-cartridge-raw-0.1
Version:   0.8
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires: git
Requires:  rhc-node
Requires:  httpd

BuildArch: noarch

%description
Provides raw http support to OpenShift

%prep
%setup -q

%build
rm -rf git_template
cp -r template/ git_template/
cd git_template
git init
git add -f .
git commit -m 'Creating template'
cd ..
git clone --bare git_template git_template.git
rm -rf git_template
touch git_template.git/refs/heads/.gitignore

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
cp -r info %{buildroot}%{cartridgedir}/
mkdir -p %{buildroot}%{cartridgedir}/info/data/
cp -r git_template.git %{buildroot}%{cartridgedir}/info/data/
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/add-module %{buildroot}%{cartridgedir}/info/hooks/add-module
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/info %{buildroot}%{cartridgedir}/info/hooks/info
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/post-install %{buildroot}%{cartridgedir}/info/hooks/post-install
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/post-remove %{buildroot}%{cartridgedir}/info/hooks/post-remove
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/reload %{buildroot}%{cartridgedir}/info/hooks/reload
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/remove-module %{buildroot}%{cartridgedir}/info/hooks/remove-module
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/restart %{buildroot}%{cartridgedir}/info/hooks/restart
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/start %{buildroot}%{cartridgedir}/info/hooks/start
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/status %{buildroot}%{cartridgedir}/info/hooks/status
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/stop %{buildroot}%{cartridgedir}/info/hooks/stop
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/update_namespace %{buildroot}%{cartridgedir}/info/hooks/update_namespace
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/preconfigure %{buildroot}%{cartridgedir}/info/hooks/preconfigure
ln -s %{cartridgedir}/../abstract-httpd/info/hooks/deploy_httpd_proxy %{buildroot}%{cartridgedir}/info/hooks/deploy_httpd_proxy

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0750,-,-) %{cartridgedir}/info/data/
%attr(0750,-,-) %{cartridgedir}/info/build/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%config(noreplace) %{cartridgedir}/info/configuration/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control

%changelog
* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.8-1
- bash usage error (dmcphers@redhat.com)
- more jenkins job work (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.7-1
- ssh -> GIT_SSH (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.6-1
- add deploy step and call from jenkins with stop start (dmcphers@redhat.com)
- job updates (dmcphers@redhat.com)
- working on jenkins build logic (dmcphers@redhat.com)

* Thu Oct 06 2011 Dan McPherson <dmcphers@redhat.com> 0.5-1
- switch to use ci type to know if client is avail (dmcphers@redhat.com)
- cleanup (dmcphers@redhat.com)
- add jenkins build kickoff to all post receives (dmcphers@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- stripping additional php bits (mmcgrath@redhat.com)
- adding base templates for all types (dmcphers@redhat.com)
- Adding health check and index (mmcgrath@redhat.com)
- fix some deconfigures for httpd proxy (dmcphers@redhat.com)

* Tue Oct 04 2011 Dan McPherson <dmcphers@redhat.com> 0.4-1
- cleanup (dmcphers@redhat.com)
- add deploy httpd proxy and migration (dmcphers@redhat.com)

* Thu Sep 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.3-1
- Initial tagging

* Thu Sep 29 2011 Mike McGrath <mmcgrath@redhat.com> 0.2-1
- new package built with tito

* Wed Sep 21 2011 Mike McGrath <mmcgrath@redhat.com> 0.1-1
- Creating initial raw cartridge
