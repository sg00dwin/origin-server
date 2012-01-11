%define cartridgedir %{_libexecdir}/li/cartridges/jbossas-7.0

Summary:   Provides JBossAS7 support
Name:      rhc-cartridge-jbossas-7.0
Version:   0.84.9
Release:   1%{?dist}
Group:     Development/Languages
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   %{name}-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:  git
BuildRequires:  java-devel >= 1:1.6.0 
BuildRequires:  jpackage-utils
Requires:  rhc-node
# When updating jboss-as7, update the alternatives link below
Requires: jboss-as7 = 7.0.2.Final
Requires:  maven3

BuildArch: noarch

%description
Provides JBossAS7 support to OpenShift

%prep
%setup -q

%build

#mkdir -p template/src/main/webapp/WEB-INF/classes
#pushd template/src/main/java > /dev/null
#/usr/bin/javac *.java -d ../webapp/WEB-INF/classes 
#popd

mkdir -p info/data
pushd template/src/main/webapp > /dev/null 
/usr/bin/jar -cvf ../../../../info/data/ROOT.war -C . .
popd

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{cartridgedir}
mkdir -p %{buildroot}/%{_sysconfdir}/libra/cartridges
ln -s %{cartridgedir}/info/configuration/ %{buildroot}/%{_sysconfdir}/libra/cartridges/%{name}
cp -r info %{buildroot}%{cartridgedir}/
cp -r template %{buildroot}%{cartridgedir}/
cp README %{buildroot}%{cartridgedir}/
ln -s %{cartridgedir}/../abstract/info/hooks/add-module %{buildroot}%{cartridgedir}/info/hooks/add-module
ln -s %{cartridgedir}/../abstract/info/hooks/info %{buildroot}%{cartridgedir}/info/hooks/info
ln -s %{cartridgedir}/../abstract/info/hooks/post-install %{buildroot}%{cartridgedir}/info/hooks/post-install
ln -s %{cartridgedir}/../abstract/info/hooks/post-remove %{buildroot}%{cartridgedir}/info/hooks/post-remove
ln -s %{cartridgedir}/../abstract/info/hooks/reload %{buildroot}%{cartridgedir}/info/hooks/reload
ln -s %{cartridgedir}/../abstract/info/hooks/remove-module %{buildroot}%{cartridgedir}/info/hooks/remove-module
ln -s %{cartridgedir}/../abstract/info/hooks/restart %{buildroot}%{cartridgedir}/info/hooks/restart
ln -s %{cartridgedir}/../abstract/info/hooks/start %{buildroot}%{cartridgedir}/info/hooks/start
ln -s %{cartridgedir}/../abstract/info/hooks/stop %{buildroot}%{cartridgedir}/info/hooks/stop
ln -s %{cartridgedir}/../abstract/info/hooks/update-namespace %{buildroot}%{cartridgedir}/info/hooks/update-namespace
ln -s %{cartridgedir}/../abstract/info/hooks/preconfigure %{buildroot}%{cartridgedir}/info/hooks/preconfigure
ln -s %{cartridgedir}/../abstract/info/hooks/deploy-httpd-proxy %{buildroot}%{cartridgedir}/info/hooks/deploy-httpd-proxy
ln -s %{cartridgedir}/../abstract/info/hooks/remove-httpd-proxy %{buildroot}%{cartridgedir}/info/hooks/remove-httpd-proxy
ln -s %{cartridgedir}/../abstract/info/hooks/force-stop %{buildroot}%{cartridgedir}/info/hooks/force-stop
ln -s %{cartridgedir}/../abstract/info/hooks/status %{buildroot}%{cartridgedir}/info/hooks/status
ln -s %{cartridgedir}/../abstract/info/hooks/add-alias %{buildroot}%{cartridgedir}/info/hooks/add-alias
ln -s %{cartridgedir}/../abstract/info/hooks/tidy %{buildroot}%{cartridgedir}/info/hooks/tidy
ln -s %{cartridgedir}/../abstract/info/hooks/remove-alias %{buildroot}%{cartridgedir}/info/hooks/remove-alias
ln -s %{cartridgedir}/../abstract/info/hooks/move %{buildroot}%{cartridgedir}/info/hooks/move

%post
# To modify an alternative you should:
# - remove the previous version if it's no longer valid
# - install the new version with an increased priority
# - set the new version as the default to be safe
alternatives --install /etc/alternatives/maven-3.0 maven-3.0 /usr/share/java/apache-maven-3.0.3 100
alternatives --set maven-3.0 /usr/share/java/apache-maven-3.0.3
alternatives --remove jbossas-7.0 /opt/jboss-as-web-7.0.1.Final
alternatives --install /etc/alternatives/jbossas-7.0 jbossas-7.0 /opt/jboss-as-7.0.2.Final 101
alternatives --set jbossas-7.0 /opt/jboss-as-7.0.2.Final
#
# Temp placeholder to add a postgresql datastore -- keep this until the
# the postgresql module is added to jboss as 7.* upstream.
mkdir -p /etc/alternatives/jbossas-7.0/modules/org/postgresql/jdbc/main
ln -fs /usr/share/java/postgresql-jdbc3.jar /etc/alternatives/jbossas-7.0/modules/org/postgresql/jdbc/main
cp -p %{cartridgedir}/info/configuration/postgresql_module.xml /etc/alternatives/jbossas-7.0/modules/org/postgresql/jdbc/main/module.xml


%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%attr(0750,-,-) %{cartridgedir}/info/hooks/
%attr(0640,-,-) %{cartridgedir}/info/data/
%attr(0755,-,-) %{cartridgedir}/info/bin/
%{cartridgedir}/template/
%config(noreplace) %{cartridgedir}/info/configuration/
%{_sysconfdir}/libra/cartridges/%{name}
%{cartridgedir}/info/changelog
%{cartridgedir}/info/control
%{cartridgedir}/info/manifest.yml
%{cartridgedir}/README

%changelog
* Wed Jan 11 2012 Dan McPherson <dmcphers@redhat.com> 0.84.9-1
- Gracefully handle threaddump in cartridges that do not support it (BZ772114)
  (aboone@redhat.com)
- Bug 773110 - added /home/wdecoste/.java (wdecoste@localhost.localdomain)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.8-1
- fix build breaks (dmcphers@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.7-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rchopra@redhat.com)
- basic descriptors for all cartridges; added primitive structure for a www-
  dynamic cartridge that will abstract all httpd processes that any cartridges
  need (e.g. php, perl, metrics, rockmongo etc). (rchopra@redhat.com)
- Fix to use correct module name + use-ccm (ramr@redhat.com)
- Fix to move to the post-install step. (ramr@redhat.com)
- Don't link abstract post-install hook as we now have a post-install hook.
  (ramr@redhat.com)
- Add postgresql driver support to jboss. (ramr@redhat.com)