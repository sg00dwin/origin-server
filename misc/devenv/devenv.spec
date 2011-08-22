%define htmldir %{_localstatedir}/www/html
%define libradir %{_localstatedir}/www/libra
%define brokerdir %{_localstatedir}/www/libra/broker
%define sitedir %{_localstatedir}/www/libra/site
%define devenvdir %{_sysconfdir}/libra/devenv
%define jenkins %{_sharedstatedir}/jenkins

Summary:   Dependencies for OpenShift development
Name:      rhc-devenv
Version:   0.76.3
Release:   1%{?dist}
Group:     Development/Libraries
License:   GPLv2
URL:       http://openshift.redhat.com
Source0:   rhc-devenv-%{version}.tar.gz

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires:  rhc
Requires:  rhc-node
Requires:  rhc-site
Requires:  rhc-broker
Requires:  rhc-cartridge-php-5.3
Requires:  rhc-cartridge-wsgi-3.2
Requires:  rhc-cartridge-rack-1.1
Requires:  rhc-cartridge-jbossas-7.0
Requires:  rhc-cartridge-perl-5.10
Requires:  rhc-cartridge-mysql-5.1
Requires:  qpid-cpp-server
Requires:  qpid-cpp-server-ssl
Requires:  puppet
Requires:  rubygem-cucumber
Requires:  rubygem-mechanize
Requires:  rubygem-mocha
Requires:  rubygem-rspec
Requires:  rubygem-nokogiri
Requires:  rubygem-openshift-sdk
Requires:  charlie
Requires:  pam

# CI Requirements
Requires:  jenkins
Requires:  tito

# Selenium Requirements
Requires:  firefox
Requires:  xorg-x11-server-Xvfb

BuildArch: noarch

%description
Provides all the development dependencies to be able to run the OpenShift tests

%prep
%setup -q

%build

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}%{devenvdir}
cp -adv * %{buildroot}%{devenvdir}

# Move over the init scripts so they get the right context
mkdir -p %{buildroot}%{_initddir}
mv %{buildroot}%{devenvdir}/init.d/* %{buildroot}%{_initddir}

mkdir -p %{buildroot}%{brokerdir}/log
mkdir -p %{buildroot}%{sitedir}/log

# Setup mcollective client log
touch %{buildroot}%{brokerdir}/log/mcollective-client.log

# Setup rails development logs
touch %{buildroot}%{brokerdir}/log/development.log
touch %{buildroot}%{sitedir}/log/development.log

# Setup the jenkins jobs
mkdir -p %{buildroot}%{jenkins}/jobs
mv %{buildroot}%{devenvdir}%{jenkins}/jobs/* %{buildroot}%{jenkins}/jobs

%clean
rm -rf %{buildroot}

%post

# Install the Selenium gems
gem install selenium-webdriver
gem install headless

# Move over all configs and scripts
cp -rf %{devenvdir}/etc/* %{_sysconfdir}
cp -rf %{devenvdir}/bin/* %{_bindir}
cp -rf %{devenvdir}/var/* %{_localstatedir}

# Move over new http configurations
cp -rf %{devenvdir}/httpd/* %{libradir}
cp -rf %{devenvdir}/httpd.conf %{sitedir}/httpd/
cp -rf %{devenvdir}/httpd.conf %{brokerdir}/httpd/
cp -f %{devenvdir}/client.cfg %{devenvdir}/server.cfg /etc/mcollective
mkdir -p %{sitedir}/httpd/logs
mkdir -p %{sitedir}/httpd/run
mkdir -p %{brokerdir}/httpd/logs
mkdir -p %{brokerdir}/httpd/run
ln -s %{sitedir}/public/* %{htmldir}
ln -s /usr/lib64/httpd/modules/ %{sitedir}/httpd/modules
ln -s /usr/lib64/httpd/modules/ %{brokerdir}/httpd/modules

# Ensure /tmp and /var/tmp aren't world usable

chmod o-rwX /tmp /var/tmp
setfacl -m u:libra_passenger:rwx /tmp
setfacl -m u:jenkins:rwx /tmp

# Jenkins specific setup
usermod -G libra_user jenkins
chown -R jenkins:jenkins /var/lib/jenkins

# TODO - fix this because having jenkins in libra_user should correct this
# However, without doing this, rake test fails for the rails sites
chmod a+r /etc/libra/controller.conf

# Allow Apache to connect to Jenkins port 8081
/usr/sbin/setsebool -P httpd_can_network_connect=on || :

# Allow polyinstantiation to work
/usr/sbin/setsebool -P allow_polyinstantiation=on || :

# Allow httpd to relay
/usr/sbin/setsebool -P httpd_can_network_relay=on || :

# Increase kernel semaphores to accomodate many httpds
echo "kernel.sem = 250  32000 32  4096" >> /etc/sysctl.conf
sysctl kernel.sem="250  32000 32  4096"

# Setup facts
/usr/bin/puppet /usr/libexec/mcollective/update_yaml.pp
crontab -u root %{devenvdir}/crontab

# enable disk quotas
/usr/bin/rhc-init-quota

# Increase max SSH connections and tries to 40
perl -p -i -e "s/^#MaxSessions .*$/MaxSessions 40/" /etc/ssh/sshd_config
perl -p -i -e "s/^#MaxStartups .*$/MaxStartups 40/" /etc/ssh/sshd_config

# Setup an empty git repository to allow code transfer
mkdir -p /root/li
git init --bare /root/li

# Restore permissions
/sbin/restorecon -R %{_sysconfdir}/qpid/pki
/sbin/restorecon -R %{libradir}

# Start services
service iptables restart
service qpidd restart
service mcollective start
service libra-site restart
service libra-broker restart
service jenkins restart
service httpd restart
chkconfig iptables on
chkconfig qpidd on
chkconfig mcollective on
chkconfig libra-site on
chkconfig libra-broker on
chkconfig jenkins on
chkconfig httpd on

# CGroup services
service cgconfig start
service cgred start
service libra-cgroups start
service libra-tc start
chkconfig cgconfig on
chkconfig cgred on
chkconfig libra-cgroups on
chkconfig libra-tc on

%files
%defattr(-,root,root,-)
%attr(0666,-,-) %{brokerdir}/log/mcollective-client.log
%attr(0666,-,-) %{brokerdir}/log/development.log
%attr(0666,-,-) %{sitedir}/log/development.log
%config(noreplace) %{jenkins}/jobs/jenkins_update/config.xml
%config(noreplace) %{jenkins}/jobs/libra_ami/config.xml
%config(noreplace) %{jenkins}/jobs/libra_ami_verify/config.xml
%config(noreplace) %{jenkins}/jobs/libra_ami_stage/config.xml
%config(noreplace) %{jenkins}/jobs/libra_ami_verify_stage/config.xml
%config(noreplace) %{jenkins}/jobs/libra_check/config.xml
%config(noreplace) %{jenkins}/jobs/libra_prune/config.xml
%config(noreplace) %{jenkins}/jobs/libra_web/config.xml
%{devenvdir}
%{_initddir}/libra-broker
%{_initddir}/libra-site

%changelog
* Mon Aug 22 2011 Dan McPherson <dmcphers@redhat.com> 0.76.3-1
- add sdk back (dmcphers@redhat.com)

* Sun Aug 21 2011 Dan McPherson <dmcphers@redhat.com> 0.76.2-1
- comment out openshift-sdk to get a build (dmcphers@redhat.com)

* Fri Aug 19 2011 Matt Hicks <mhicks@redhat.com> 0.76.1-1
- Adding OpenShift SDK to DevEnv (mhicks@redhat.com)
- bump spec numbers (dmcphers@redhat.com)

* Mon Aug 15 2011 Dan McPherson <dmcphers@redhat.com> 0.75.5-1
- Setting timeout back to normal (mmcgrath@redhat.com)

* Mon Aug 15 2011 Matt Hicks <mhicks@redhat.com> 0.75.4-1
- increasing connection timeout (mmcgrath@redhat.com)

* Thu Aug 11 2011 Matt Hicks <mhicks@redhat.com> 0.75.3-1
- Reducing number of initial passenger instances (mhicks@redhat.com)

* Mon Aug 08 2011 Matt Hicks <mhicks@redhat.com> 0.75.2-1
- Adding config for devenv (mhicks@redhat.com)

* Thu Jul 21 2011 Dan McPherson <dmcphers@redhat.com> 0.75.1-1
- bump spec numbers (dmcphers@redhat.com)
- fixed cert_password bug (twiest@redhat.com)
- added a description for -m to make-certs.txt (twiest@redhat.com)
- Added makecerts (mmcgrath@redhat.com)

* Mon Jul 18 2011 Dan McPherson <dmcphers@redhat.com> 0.74.9-1
- added months_valid option (-m) to make-certs.sh (twiest@redhat.com)
- call pam_namespace (mmcgrath@redhat.com)
- Adding no_unmount_on_close (mmcgrath@redhat.com)

* Fri Jul 15 2011 Dan McPherson <dmcphers@redhat.com> 0.74.8-1
- turn libra_check to disabled (dmcphers@redhat.com)

* Fri Jul 15 2011 Dan McPherson <dmcphers@redhat.com> 0.74.7-1
- jenkins updates (dmcphers@redhat.com)
- libra_check updates (dmcphers@redhat.com)
- Test commit (mhicks@redhat.com)
- jenkins update (dmcphers@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.6-1
- Adding system-auth" (mmcgrath@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.5-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Adding polyinstantiation (mmcgrath@redhat.com)
- test case updates (dmcphers@redhat.com)
- enabling namespace (mmcgrath@redhat.com)

* Wed Jul 13 2011 Dan McPherson <dmcphers@redhat.com> 0.74.4-1
- Adding namesapce (mmcgrath@redhat.com)

* Tue Jul 12 2011 Mike McGrath <mmcgrath@redhat.com> 0.74.3-1
- Added explicit reqiures for pam/pam namesapce (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Updating qpid SSL certs (mhicks@redhat.com)
- Adding pam_namespace and polyinst /tmp (mmcgrath@redhat.com)

* Tue Jul 12 2011 Dan McPherson <dmcphers@redhat.com> 0.74.2-1
- Automatic commit of package [rhc-devenv] release [0.74.1-1].
  (dmcphers@redhat.com)
- bumping spec numbers (dmcphers@redhat.com)
- Automatic commit of package [rhc-devenv] release [0.73.9-1].
  (dmcphers@redhat.com)
- fix prune not to delete stage amis (dmcphers@redhat.com)
- Automatic commit of package [rhc-devenv] release [0.73.8-1].
  (edirsh@redhat.com)
- Updating verify job (mhicks@redhat.com)
- Automatic commit of package [rhc-devenv] release [0.73.7-1].
  (dmcphers@redhat.com)
- fix devenv build (dmcphers@redhat.com)
- Automatic commit of package [rhc-devenv] release [0.73.6-1].
  (dmcphers@redhat.com)
- let jenkins use tmp (dmcphers@redhat.com)
- Added mysql and charlie (mmcgrath@redhat.com)
- cleanup unused vars (dmcphers@redhat.com)
- Automatic commit of package [rhc-devenv] release [0.73.5-1].
  (dmcphers@redhat.com)
- removing mysql until it is available (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)
- Added mysql (mmcgrath@redhat.com)
- Switching the stage build to use the stage branch (mhicks@redhat.com)
- Automatic commit of package [rhc-devenv] release [0.73.4-1].
  (mhicks@redhat.com)
- Adding support for staging releases on the new tag (mhicks@redhat.com)

* Mon Jul 11 2011 Dan McPherson <dmcphers@redhat.com> 0.74.1-1
- bumping spec numbers (dmcphers@redhat.com)

* Sat Jul 09 2011 Dan McPherson <dmcphers@redhat.com> 0.73.9-1
- fix prune not to delete stage amis (dmcphers@redhat.com)

* Fri Jul 01 2011 Emily Dirsh <edirsh@redhat.com> 0.73.8-1
- Updating verify job (mhicks@redhat.com)

* Thu Jun 30 2011 Dan McPherson <dmcphers@redhat.com> 0.73.7-1
- fix devenv build (dmcphers@redhat.com)

* Thu Jun 30 2011 Dan McPherson <dmcphers@redhat.com> 0.73.6-1
- let jenkins use tmp (dmcphers@redhat.com)
- Added mysql and charlie (mmcgrath@redhat.com)
- cleanup unused vars (dmcphers@redhat.com)

* Wed Jun 29 2011 Dan McPherson <dmcphers@redhat.com> 0.73.5-1
- removing mysql until it is available (mmcgrath@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- add nurture call for git push (dmcphers@redhat.com)
- Added mysql (mmcgrath@redhat.com)
- Switching the stage build to use the stage branch (mhicks@redhat.com)

* Tue Jun 28 2011 Matt Hicks <mhicks@redhat.com> 0.73.4-1
- Adding support for staging releases on the new tag (mhicks@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.3-1
- set default apps to 5 (mmcgrath@redhat.com)

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.2-1
- 

* Mon Jun 27 2011 Dan McPherson <dmcphers@redhat.com> 0.73.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.72.24-1
- 

* Thu Jun 23 2011 Dan McPherson <dmcphers@redhat.com> 0.72.23-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- allow for forcing of IP (mmcgrath@redhat.com)

* Wed Jun 22 2011 Dan McPherson <dmcphers@redhat.com> 0.72.22-1
- move mcollective client log (dmcphers@redhat.com)

* Tue Jun 21 2011 Dan McPherson <dmcphers@redhat.com> 0.72.21-1
- adding setfacl (mmcgrath@redhat.com)
- chmoding (mmcgrath@redhat.com)

* Tue Jun 14 2011 Matt Hicks <mhicks@redhat.com> 0.72.20-1
- Adding perl to devenv (mmcgrath@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.19-1
- More jenkins job updates (mhicks@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.18-1
- Artifact retention tuning for Jenkins (mhicks@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.17-1
- Jenkins job definition updates (mhicks@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.16-1
- Updating Jenkins libra_web config (mhicks@redhat.com)
- Selenium test cleanup (mhicks@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.15-1
- DevEnv Selenium Cleanup (mhicks@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.14-1
- Removing file that failed RPM build (mhicks@redhat.com)

* Fri Jun 10 2011 Matt Hicks <mhicks@redhat.com> 0.72.13-1
- Cleanup of old job (mhicks@redhat.com)
- lib macro fix (mhicks@redhat.com)
- Selenium DevEnv setup / cleanup (mhicks@redhat.com)
- Updating Jenkins config not to install devenv on update (mhicks@redhat.com)

* Thu Jun 09 2011 Matt Hicks <mhicks@redhat.com> 0.72.12-1
- Switching build notifications to the list (mhicks@redhat.com)

* Thu Jun 09 2011 Matt Hicks <mhicks@redhat.com> 0.72.11-1
- DevEnv enhancements (mhicks@redhat.com)

* Thu Jun 09 2011 Matt Hicks <mhicks@redhat.com> 0.72.10-1
- Moving binary selenium content to the devenv RPM structure
  (mhicks@redhat.com)
* Wed Jun 08 2011 Matt Hicks <mhicks@redhat.com> 0.72.9-1
- Allowing Apache to connect to non-standard port for Jenkins
  (mhicks@redhat.com)

* Wed Jun 08 2011 Matt Hicks <mhicks@redhat.com> 0.72.8-1
- Adding firefox profile to spec (mhicks@redhat.com)
- Job renaming and spec config cleanup (mhicks@redhat.com)

* Wed Jun 08 2011 Matt Hicks <mhicks@redhat.com> 0.72.7-1
- Making sure the permissions are set for jenkins dir (mhicks@redhat.com)
- Adding jenkins setup to devenv (mhicks@redhat.com)

* Mon Jun 06 2011 Dan McPherson <dmcphers@redhat.com> 0.72.6-1
- adding jenkins to li-devenv (dmcphers@redhat.com)

* Fri Jun 03 2011 Matt Hicks <mhicks@redhat.com> 0.72.5-1
- Installation fix (mhicks@redhat.com)
- Fixing SELinux context on init scripts (mhicks@redhat.com)
- DevEnv RPM Updating and spec additions (mhicks@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.4-1
- Automatic commit of package [rhc-devenv] release [0.72.3-1].
  (dmcphers@redhat.com)

* Wed Jun 01 2011 Dan McPherson <dmcphers@redhat.com> 0.72.3-1
- Adding back RHUI Optional setup (mhicks@redhat.com)
- More build improvements (mhicks@redhat.com)

* Tue May 31 2011 Matt Hicks <mhicks@redhat.com> 0.72.2-1
- dep updates (dmcphers@redhat.com)
- fix devenv build (dmcphers@redhat.com)

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-3
- Changed source file structure to remove 'devenv' dir

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-2
- Spec cleanup

* Thu May 26 2011 Matt Hicks <mhicks@redhat.com> 0.72.1-1
- Initial restructuring
