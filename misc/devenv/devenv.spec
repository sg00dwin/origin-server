%define htmldir %{_localstatedir}/www/html
%define libradir %{_localstatedir}/www/libra
%define brokerdir %{_localstatedir}/www/libra/broker
%define sitedir %{_localstatedir}/www/libra/site
%define devenvdir %{_sysconfdir}/libra/devenv
%define jenkins %{_sharedstatedir}/jenkins

Summary:   Dependencies for OpenShift development
Name:      rhc-devenv
Version:   0.72.20
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
Requires:  qpid-cpp-server
Requires:  qpid-cpp-server-ssl
Requires:  puppet
Requires:  rubygem-cucumber
Requires:  rubygem-mechanize
Requires:  rubygem-mocha
Requires:  rubygem-rspec
Requires:  rubygem-nokogiri

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

# Setup mcollective client log
mkdir -p %{buildroot}%{_tmppath}/log
touch %{buildroot}%{_tmppath}/mcollective-client.log

mkdir -p %{buildroot}%{brokerdir}/log
mkdir -p %{buildroot}%{sitedir}/log

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

# Jenkins specific setup
usermod -G libra_user jenkins
chown -R jenkins:jenkins /var/lib/jenkins

# TODO - fix this because having jenkins in libra_user should correct this
# However, without doing this, rake test fails for the rails sites
chmod a+r /etc/libra/controller.conf

# Allow Apache to connect to Jenkins port 8081
/usr/sbin/setsebool -P httpd_can_network_connect=on || :

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
%attr(0666,-,-) %{_tmppath}/mcollective-client.log
%attr(0666,-,-) %{brokerdir}/log/development.log
%attr(0666,-,-) %{sitedir}/log/development.log
%config(noreplace) %{jenkins}/jobs/jenkins_update/config.xml
%config(noreplace) %{jenkins}/jobs/libra_ami/config.xml
%config(noreplace) %{jenkins}/jobs/libra_ami_verify/config.xml
%config(noreplace) %{jenkins}/jobs/libra_check/config.xml
%config(noreplace) %{jenkins}/jobs/libra_prune/config.xml
%config(noreplace) %{jenkins}/jobs/libra_web/config.xml
%{devenvdir}
%{_initddir}/libra-broker
%{_initddir}/libra-site

%changelog
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
