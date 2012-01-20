%define htmldir %{_localstatedir}/www/html
%define libradir %{_localstatedir}/www/libra
%define brokerdir %{_localstatedir}/www/libra/broker
%define sitedir %{_localstatedir}/www/libra/site
%define devenvdir %{_sysconfdir}/libra/devenv
%define jenkins %{_sharedstatedir}/jenkins

Summary:   Dependencies for OpenShift development
Name:      rhc-devenv
Version:   0.85.2
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
Requires:  rhc-cartridge-phpmyadmin-3.4
Requires:  rhc-cartridge-jenkins-1.4
Requires:  rhc-cartridge-raw-0.1
Requires:  rhc-cartridge-jenkins-client-1.4
Requires:  rhc-cartridge-metrics-0.1
Requires:  rhc-cartridge-mongodb-2.0
Requires:  rhc-cartridge-phpmoadmin-1.0
Requires:  rhc-cartridge-rockmongo-1.1
Requires:  rhc-cartridge-10gen-mms-agent-0.1
Requires:  rhc-cartridge-postgresql-8.4
Requires:  qpid-cpp-server
Requires:  qpid-cpp-server-ssl
Requires:  puppet
Requires:  rubygem-cucumber
Requires:  rubygem-mechanize
Requires:  rubygem-mocha
Requires:  rubygem-rspec
Requires:  rubygem-nokogiri
Requires:  charlie
Requires:  pam

# CI Requirements
Requires:  jenkins
Requires:  tito

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

# Install the Sauce Labs gems
gem install sauce --no-rdoc --no-ri
gem install zip --no-rdoc --no-ri

# Move over all configs and scripts
cp -rf %{devenvdir}/etc/* %{_sysconfdir}
cp -rf %{devenvdir}/bin/* %{_bindir}
cp -rf %{devenvdir}/var/* %{_localstatedir}

# Add rsync key to authorized keys
cat %{brokerdir}/config/keys/rsync_id_rsa.pub >> /root/.ssh/authorized_keys

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

# Move ephemeral port range to accommodate app proxies
echo "net.ipv4.ip_local_port_range = 15000 35535" >> /etc/sysctl.conf
sysctl net.ipv4.ip_local_port_range="15000 35535"

# Setup facts
/usr/libexec/mcollective/update_yaml.rb
crontab -u root %{devenvdir}/crontab

# enable disk quotas
/usr/bin/rhc-init-quota

# Setup swap for devenv
[ -f /.swap ] || ( /bin/dd if=/dev/zero of=/.swap bs=1024 count=1024000
    /sbin/mkswap -f /.swap
    /sbin/swapon /.swap
    echo "/.swap swap   swap    defaults        0 0" >> /etc/fstab
)

# Increase max SSH connections and tries to 40
perl -p -i -e "s/^#MaxSessions .*$/MaxSessions 40/" /etc/ssh/sshd_config
perl -p -i -e "s/^#MaxStartups .*$/MaxStartups 40/" /etc/ssh/sshd_config

# Setup an empty git repository to allow code transfer
mkdir -p /root/li
#mkdir -p /root/cloud-sdk
git init --bare /root/li
git init --bare /root/os-client-tools
#git init --bare /root/cloud-sdk

# Restore permissions
/sbin/restorecon -R %{_sysconfdir}/qpid/pki
/sbin/restorecon -R %{libradir}

# Start services
service iptables restart
service qpidd restart
service mcollective start
service libra-datastore configure
service libra-datastore start
service libra-site restart
service libra-broker restart
service jenkins restart
service httpd restart
service sshd restart
chkconfig iptables on
chkconfig qpidd on
chkconfig mcollective on
chkconfig libra-datastore on
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

# Populate mcollective certs
cd /etc/mcollective/ssl/clients
openssl genrsa -out mcollective-private.pem 1024
openssl rsa -in mcollective-private.pem -out mcollective-public.pem -outform PEM -pubout
chown libra_passenger:root mcollective-private.pem
chmod 460 mcollective-private.pem
cd

# Move static puppet certs in devenv
mkdir -p /var/lib/puppet/ssl/public_keys/
mkdir -p /var/lib/puppet/ssl/private_keys/
cp -f %{devenvdir}/puppet-public.pem /var/lib/puppet/ssl/public_keys/localhost.localdomain.pem
cp -f %{devenvdir}/puppet-private.pem /var/lib/puppet/ssl/private_keys/localhost.localdomain.pem

%files
%defattr(-,root,root,-)
%attr(0666,-,-) %{brokerdir}/log/mcollective-client.log
%attr(0666,-,-) %{brokerdir}/log/development.log
%attr(0666,-,-) %{sitedir}/log/development.log
%config(noreplace) %{jenkins}/jobs/*/*
%{jenkins}/jobs/sync.rb
%{devenvdir}
%{_initddir}/libra-datastore
%{_initddir}/libra-broker
%{_initddir}/libra-site
%{_initddir}/sauce-connect

%changelog
* Thu Jan 19 2012 Dan McPherson <dmcphers@redhat.com> 0.85.2-1
- Move libra-datastore to devenv.spec (rpenta@redhat.com)

* Fri Jan 13 2012 Dan McPherson <dmcphers@redhat.com> 0.85.1-1
- bump spec numbers (dmcphers@redhat.com)

* Fri Jan 13 2012 Alex Boone <aboone@redhat.com> 0.84.13-1
- Re-issuing devenv Qpid certs -- now valid through Jan 13, 2013
  (aboone@redhat.com)

* Thu Jan 12 2012 Dan McPherson <dmcphers@redhat.com> 0.84.12-1
- Add a Jenkins job to build and test the Java client (aboone@redhat.com)
- Persist minor change to libra_ami Jenkins job config (aboone@redhat.com)
- Persist Jenkins config for Selenium test jobs (aboone@redhat.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.84.11-1
- Revert 9619834, dependency belongs in site.spec (aboone@redhat.com)

* Mon Jan 09 2012 Dan McPherson <dmcphers@redhat.com> 0.84.10-1
- Require ruby-geoip package in devenv in preparation for US1455
  (aboone@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.9-1
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Add postgresql cartridge to the list to install on the devenv.
  (ramr@redhat.com)

* Fri Jan 06 2012 Dan McPherson <dmcphers@redhat.com> 0.84.8-1
- Add output of rhc-iptables. (rmillner@redhat.com)

* Thu Dec 22 2011 Dan McPherson <dmcphers@redhat.com> 0.84.7-1
- removing more of server-common (dmcphers@redhat.com)

* Wed Dec 21 2011 Dan McPherson <dmcphers@redhat.com> 0.84.6-1
- namespace.conf - removed extra line 12 21 2011 (tkramer@redhat.com)

* Wed Dec 21 2011 Mike McGrath <mmcgrath@redhat.com> 0.84.5-1
- namespace.ini - deleted extra config file 12 21 2011 (tkramer@redhat.com)
- namespace.ini change location of polyinstantiated files 12 21 2011
  (tkramer@redhat.com)

* Fri Dec 16 2011 Dan McPherson <dmcphers@redhat.com> 0.84.4-1
- some cleanup of server-common (dmcphers@redhat.com)

* Thu Dec 15 2011 Dan McPherson <dmcphers@redhat.com> 0.84.3-1
- use the right path this time (dmcphers@redhat.com)

* Thu Dec 15 2011 Dan McPherson <dmcphers@redhat.com> 0.84.2-1
- mirage merging fixes (dmcphers@redhat.com)

* Wed Dec 14 2011 Dan McPherson <dmcphers@redhat.com> 0.84.1-1
- bump spec numbers (dmcphers@redhat.com)
- rpm work (dmcphers@redhat.com)

* Fri Dec 09 2011 Mike McGrath <mmcgrath@redhat.com> 0.83.7-1
- adding rhc-cartridge-10gen-mms-agent-0.1 to the devenv spec file to be
  installed on the devenv  and adding the dependency on mms-agent source rpm on
  the rhc-cartridge-10gen-mms-agent-0.1 spec file (abhgupta@redhat.com)

* Fri Dec 09 2011 Mike McGrath <mmcgrath@redhat.com> 0.83.6-1
- updating to libra-devel (mmcgrath@redhat.com)

* Wed Dec 07 2011 Matt Hicks <mhicks@redhat.com> 0.83.5-1
- Switching to the 6.2 repos (mhicks@redhat.com)

* Wed Dec 07 2011 Matt Hicks <mhicks@redhat.com> 0.83.4-1
- Skipping rdoc and ri install (mhicks@redhat.com)

* Tue Dec 06 2011 Alex Boone <aboone@redhat.com> 0.83.3-1
- Merge branch 'master' of ssh://git/srv/git/li (aboone@redhat.com)
- Refactor to use Selenium 2, remove unused code (aboone@redhat.com)
- Adding port forwarding allowance, explicit removal of gatway ports
  (mmcgrath@redhat.com)
- added virtual host info to the log format (twiest@redhat.com)

* Fri Dec 02 2011 Dan McPherson <dmcphers@redhat.com> 0.83.2-1
- adding rockmongo (mmcgrath@redhat.com)

* Thu Dec 01 2011 Dan McPherson <dmcphers@redhat.com> 0.83.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Nov 30 2011 Dan McPherson <dmcphers@redhat.com> 0.82.10-1
- remove cloud-sdk from prereqs (dmcphers@redhat.com)

* Tue Nov 29 2011 Dan McPherson <dmcphers@redhat.com> 0.82.9-1
- removing un-needed sudoers file (mmcgrath@redhat.com)
- prep work for idler/restorer (mmcgrath@redhat.com)

* Mon Nov 21 2011 Dan McPherson <dmcphers@redhat.com> 0.82.8-1
- added phpmoadmin-1.0 (rchopra@redhat.com)

* Fri Nov 18 2011 Dan McPherson <dmcphers@redhat.com> 0.82.7-1
- moving logic to abstract from li-controller (dmcphers@redhat.com)

* Fri Nov 18 2011 Dan McPherson <dmcphers@redhat.com> 0.82.6-1
- fix build (dmcphers@redhat.com)

* Thu Nov 17 2011 Dan McPherson <dmcphers@redhat.com> 0.82.5-1
- cloud-sdk req (dmcphers@redhat.com)
- Updating DevEnv with current Jenkins job definitions (mhicks@redhat.com)

* Tue Nov 15 2011 Dan McPherson <dmcphers@redhat.com> 0.82.4-1
- Added mongodb to devenv (mmcgrath@redhat.com)

* Tue Nov 15 2011 Dan McPherson <dmcphers@redhat.com> 0.82.3-1
- add mongo req (dmcphers@redhat.com)

* Sat Nov 12 2011 Dan McPherson <dmcphers@redhat.com> 0.82.2-1
- added helpful comment for 5671 (mmcgrath@redhat.com)
- Removing the Selenium WebDriver dependencies (mhicks@redhat.com)

* Thu Nov 10 2011 Dan McPherson <dmcphers@redhat.com> 0.82.1-1
- trying to remove the sslverify and better error catching running sync and
  build (dmcphers@redhat.com)
- bump spec numbers (dmcphers@redhat.com)

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.15-1
- use li repo jenkins (dmcphers@redhat.com)

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.14-1
- Needed to create the run dir (mhicks@redhat.com)

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.13-1
- 

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.12-1
- Couple more sauce components needed (mhicks@redhat.com)

* Wed Nov 09 2011 Dan McPherson <dmcphers@redhat.com> 0.81.11-1
- Adding sauce connect service script (mhicks@redhat.com)

* Tue Nov 08 2011 Alex Boone <aboone@redhat.com> 0.81.10-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (tkramer@redhat.com)
- Updated commets in mcollective area (tkramer@redhat.com)

* Mon Nov 07 2011 Dan McPherson <dmcphers@redhat.com> 0.81.9-1
- 

* Mon Nov 07 2011 Dan McPherson <dmcphers@redhat.com> 0.81.8-1
- Bug 751743 (dmcphers@redhat.com)
- Using the new RHUI client for Amazon (mhicks@redhat.com)

* Sun Nov 06 2011 Dan McPherson <dmcphers@redhat.com> 0.81.7-1
- give better errors on sync with build failures (dmcphers@redhat.com)

* Sat Nov 05 2011 Dan McPherson <dmcphers@redhat.com> 0.81.6-1
- update rotate logs (dmcphers@redhat.com)
- update rotate logs (dmcphers@redhat.com)

* Fri Nov 04 2011 Dan McPherson <dmcphers@redhat.com> 0.81.5-1
- Updated file perms for mcollective private key. (tkramer@redhat.com)

* Fri Nov 04 2011 Dan McPherson <dmcphers@redhat.com> 0.81.4-1
- Updated for mcollective changes (tkramer@redhat.com)
- Updated to use localhost.localdomain.pem cert names (tkramer@redhat.com)
- Updated server.cfg to use localhost.localdomain.pem for cert names
  (tkramer@redhat.com)

* Thu Nov 03 2011 Dan McPherson <dmcphers@redhat.com> 0.81.3-1
- Update to put AES encryption in mcollective for devenv. (tkramer@redhat.com)

* Thu Nov 03 2011 Dan McPherson <dmcphers@redhat.com>
- Update to put AES encryption in mcollective for devenv. (tkramer@redhat.com)

* Wed Nov 02 2011 Tim Kramer <tkramer@redhat.com> 0.81.1.3
- bump spec numbers and added AES to mcollective (tkramer@redhat.com)

* Thu Oct 27 2011 Dan McPherson <dmcphers@redhat.com> 0.81.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Oct 24 2011 Dan McPherson <dmcphers@redhat.com> 0.80.11-1
- Added override option in node.conf for public_hostname (twiest@redhat.com)

* Sat Oct 22 2011 Dan McPherson <dmcphers@redhat.com> 0.80.10-1
- trying again with correct version (dmcphers@redhat.com)

* Sat Oct 22 2011 Dan McPherson <dmcphers@redhat.com> 0.80.9-1
- remove extra install (dmcphers@redhat.com)

* Fri Oct 21 2011 Dan McPherson <dmcphers@redhat.com> 0.80.8-1
- try adding a direct ref to ffi (dmcphers@redhat.com)

* Fri Oct 21 2011 Dan McPherson <dmcphers@redhat.com> 0.80.7-1
- Added metrics req (mmcgrath@redhat.com)

* Wed Oct 19 2011 Dan McPherson <dmcphers@redhat.com> 0.80.6-1
- added months-valid param for the CA creation in make-certs.sh
  (twiest@redhat.com)
- enable swap for devenv (mmcgrath@redhat.com)

* Sat Oct 15 2011 Dan McPherson <dmcphers@redhat.com> 0.80.5-1
- 

* Sat Oct 15 2011 Dan McPherson <dmcphers@redhat.com> 0.80.4-1
- missed a mcs_level in start (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.3-1
- change custom workspace (dmcphers@redhat.com)

* Fri Oct 14 2011 Dan McPherson <dmcphers@redhat.com> 0.80.2-1
- just use verbose instead (dmcphers@redhat.com)
- put output from ssh (dmcphers@redhat.com)
- add verbose to yum update (dmcphers@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.80.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Oct 13 2011 Dan McPherson <dmcphers@redhat.com> 0.78.13-1
- fix devenv spec (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.78.12-1
- add nameserver to resolve.conf (dmcphers@redhat.com)

* Wed Oct 12 2011 Dan McPherson <dmcphers@redhat.com> 0.78.11-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- updating qpid certs (mmcgrath@redhat.com)
- remove libra_web (dmcphers@redhat.com)
- libra_ami kicks off libra_ami_update (dmcphers@redhat.com)
- switch libra_ami to build devenv-clean (dmcphers@redhat.com)
- retry on invalid launch (dmcphers@redhat.com)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.78.10-1
- getting jenkins stable working (dmcphers@redhat.com)

* Tue Oct 11 2011 Dan McPherson <dmcphers@redhat.com> 0.78.9-1
- switch to jenkins stable repo (dmcphers@redhat.com)

* Mon Oct 10 2011 Dan McPherson <dmcphers@redhat.com> 0.78.8-1
- dont enable timeout value (dmcphers@redhat.com)
- bug 744660 (dmcphers@redhat.com)

* Fri Oct 07 2011 Thomas Wiest <twiest@redhat.com> 0.78.7-1
- Added phpmyadmin cartridge to devenv.spec requires (twiest@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.78.6-1
- changing to use libra_tmp_t (mmcgrath@redhat.com)
- Adding namespace init (mmcgrath@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.78.5-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- redirect output to facts.yaml (mmcgrath@redhat.com)

* Wed Oct 05 2011 Dan McPherson <dmcphers@redhat.com> 0.78.4-1
- Adding new sshd config to allow for AcceptEnv (mmcgrath@redhat.com)

* Tue Oct 04 2011 Dan McPherson <dmcphers@redhat.com> 0.78.3-1
- replace update_yaml.pp with update_yaml.rb (blentz@redhat.com)

* Mon Oct 03 2011 Dan McPherson <dmcphers@redhat.com> 0.78.2-1
- changing the default libra_server (mmcgrath@redhat.com)

* Thu Sep 29 2011 Dan McPherson <dmcphers@redhat.com> 0.78.1-1
- bump spec numbers (dmcphers@redhat.com)

* Tue Sep 27 2011 Dan McPherson <dmcphers@redhat.com> 0.77.5-1
- add new client to sync and update (dmcphers@redhat.com)

* Thu Sep 22 2011 Dan McPherson <dmcphers@redhat.com> 0.77.4-1
- turn off sslverify for now (dmcphers@redhat.com)
- Adding auto-sync for Jenkins -> DevEnv (mhicks@redhat.com)

* Thu Sep 15 2011 Dan McPherson <dmcphers@redhat.com> 0.77.3-1
- adding iv encryption (dmcphers@redhat.com)
- broker auth fixes - functional for adding token (dmcphers@redhat.com)
- move broker_auth_secret to controller.conf (dmcphers@redhat.com)

* Wed Sep 14 2011 Dan McPherson <dmcphers@redhat.com> 0.77.2-1
- unset x-forwarded-for (mmcgrath@redhat.com)

* Thu Sep 01 2011 Dan McPherson <dmcphers@redhat.com> 0.77.1-1
- bump spec numbers (dmcphers@redhat.com)

* Mon Aug 29 2011 Dan McPherson <dmcphers@redhat.com> 0.76.7-1
- devenv now pulls in the jenkins cartridge (mmcgrath@redhat.com)

* Thu Aug 25 2011 Dan McPherson <dmcphers@redhat.com> 0.76.6-1
- change rsa_key_file to ssh_key_file and change not found to warning
  (dmcphers@redhat.com)

* Thu Aug 25 2011 Matt Hicks <mhicks@redhat.com> 0.76.5-1
- Adding initial repo for the openshift-sdk repo (mhicks@redhat.com)

* Wed Aug 24 2011 Dan McPherson <dmcphers@redhat.com> 0.76.4-1
- add to client tools the ability to specify your rsa key file as well as
  default back to id_rsa as a last resort (dmcphers@redhat.com)

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
