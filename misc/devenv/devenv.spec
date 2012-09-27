%define htmldir %{_localstatedir}/www/html
%define libradir %{_localstatedir}/www/stickshift
%define brokerdir %{_localstatedir}/www/stickshift/broker
%define sitedir %{_localstatedir}/www/stickshift/site
%define devenvdir %{_sysconfdir}/stickshift/devenv
%define jenkins %{_sharedstatedir}/jenkins
%define policydir %{_datadir}/selinux/packages

Summary:   Dependencies for OpenShift development
Name:      rhc-devenv
Version: 0.100.6
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
Requires:  cartridge-php-5.3
Requires:  cartridge-python-2.6
Requires:  cartridge-ruby-1.8
Requires:  cartridge-jbossas-7
Requires:  cartridge-jbosseap-6.0
Requires:  cartridge-perl-5.10
Requires:  cartridge-mysql-5.1
Requires:  cartridge-phpmyadmin-3.4
Requires:  cartridge-jenkins-1.4
Requires:  cartridge-diy-0.1
Requires:  cartridge-jenkins-client-1.4
Requires:  cartridge-metrics-0.1
Requires:  cartridge-mongodb-2.2
Requires:  cartridge-phpmoadmin-1.0
Requires:  cartridge-rockmongo-1.1
Requires:  cartridge-10gen-mms-agent-0.1
Requires:  cartridge-postgresql-8.4
Requires:  cartridge-cron-1.4
Requires:  cartridge-haproxy-1.4
Requires:  cartridge-nodejs-0.6
Requires:  cartridge-ruby-1.9
Requires:  cartridge-zend-5.6
Requires:  activemq
Requires:  activemq-client
#Requires:  qpid-cpp-server
#Requires:  qpid-cpp-server-ssl
Requires:  puppet
Requires:  rubygem-cucumber
Requires:  rubygem-mechanize
Requires:  rubygem-mocha
Requires:  rubygem-rspec
Requires:  rubygem-webmock
Requires:  rubygem-nokogiri
Requires:  rubygem-rcov
Requires:  charlie
Requires:  pam
Requires:  pam-devel
Requires:  bind

# CI Requirements
Requires:  jenkins
Requires:  tito

# Drupal Requirements
Requires:  php-domxml-php4-php5
Requires:  php-gd
Requires:  php-mbstring
Requires:  php-mysql
Requires:  php-pdo
Requires:  php-pear-MDB2-Driver-mysql
Requires:  php-pear-MDB2-Driver-mysqli
Requires:  php-pecl-apc
Requires:  php-soap
Requires:  php-tidy
Requires:  drupal6
Requires:  drupal6-drush
# Note: this RPM has a fix for getting mysql
# running in the devenv w/o breaking because
# of pam_namespace.
Requires:  drupal6-openshift-devenv-dbdump
#
Requires:  drupal6-addthis
Requires:  drupal6-admin_menu
Requires:  drupal6-advanced-help
Requires:  drupal6-ajax_poll
Requires:  drupal6-better_formats
Requires:  drupal6-block_class
Requires:  drupal6-calendar
Requires:  drupal6-cck
Requires:  drupal6-comment_bonus_api
Requires:  drupal6-context
Requires:  drupal6-context_menu_block
Requires:  drupal6-ctools
Requires:  drupal6-custom_breadcrumbs
Requires:  drupal6-date
Requires:  drupal6-devel
Requires:  drupal6-diff
Requires:  drupal6-eazylaunch
Requires:  drupal6-emfield
Requires:  drupal6-faq
Requires:  drupal6-features
Requires:  drupal6-filefield
Requires:  drupal6-fivestar
Requires:  drupal6-flag
Requires:  drupal6-freelinking
Requires:  drupal6-geshifilter
Requires:  drupal6-geoip
Requires:  drupal6-homebox
Requires:  drupal6-image
Requires:  drupal6-image_resize_filter
Requires:  drupal6-imageapi
Requires:  drupal6-imagecache

Requires:  drupal6-imagecache_profiles
Requires:  drupal6-imagefield
Requires:  drupal6-insert
Requires:  drupal6-jquery_ui-lib
Requires:  drupal6-link
Requires:  drupal6-markdown
Requires:  drupal6-media_vimeo
Requires:  drupal6-media_tudou
Requires:  drupal6-media_youtube
Requires:  drupal6-media_youku
Requires:  drupal6-mediawiki_filter
Requires:  drupal6-menu_block
Requires:  drupal6-messaging
Requires:  drupal6-notifications
Requires:  drupal6-og
Requires:  drupal6-openshift-custom_forms
Requires:  drupal6-openshift-features-blogs
Requires:  drupal6-openshift-features-forums
Requires:  drupal6-openshift-features-front_page
Requires:  drupal6-openshift-features-global_settings
Requires:  drupal6-openshift-features-reporting_csv_views
Requires:  drupal6-openshift-features-rules_by_category
Requires:  drupal6-openshift-features-user_profile
Requires:  drupal6-openshift-features-recent_activity_report
Requires:  drupal6-openshift-features-video
Requires:  drupal6-openshift-modals
Requires:  drupal6-openshift-og_comment_perms
Requires:  drupal6-openshift-redhat_acquia
Requires:  drupal6-openshift-redhat_events
Requires:  drupal6-openshift-redhat_frontpage
Requires:  drupal6-openshift-redhat_ideas
Requires:  drupal6-openshift-redhat_sso
Requires:  drupal6-openshift-theme
Requires:  drupal6-pathauto
Requires:  drupal6-path_redirect
Requires:  drupal6-prepopulate
Requires:  drupal6-rules
Requires:  drupal6-stringoverrides
Requires:  drupal6-token
Requires:  drupal6-user_badges
Requires:  drupal6-userpoints
Requires:  drupal6-userpoints_votingapi
Requires:  drupal6-vertical_tabs
Requires:  drupal6-views
Requires:  drupal6-views_bonus
Requires:  drupal6-views_customfield
Requires:  drupal6-vote_up_down
Requires:  drupal6-votingapi
Requires:  drupal6-wikitools
Requires:  drupal6-wysiwyg
Requires:  drupal6-openshift-features-community_wiki

# Security RKHunter Requirements
Requires:  rkhunter

# Security OpenSCAP Requirements
Requires:  openscap
Requires:  openscap-content
Requires:  openscap-extra-probes
Requires:  openscap-python
Requires:  openscap-utils
Requires:  html2text

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

# Add the SELinux policy files
mkdir -p %{buildroot}%{policydir}
cp %{buildroot}%{devenvdir}%{policydir}/* %{buildroot}%{policydir} 

%clean
rm -rf %{buildroot}

%post

# Install the Sauce Labs gems
gem install sauce --no-rdoc --no-ri
gem install zip --no-rdoc --no-ri

# Install hub for automatic pull request testing
gem install hub --no-rdoc --no-ri

# Move over all configs and scripts
cp -rf %{devenvdir}/etc/* %{_sysconfdir}
cp -rf %{devenvdir}/bin/* %{_bindir}
cp -rf %{devenvdir}/var/* %{_localstatedir}

# Add rsync key to authorized keys
cat %{brokerdir}/config/keys/rsync_id_rsa.pub >> /root/.ssh/authorized_keys

# Add deploy key
cp -rf %{devenvdir}/root/.ssh/* /root/.ssh/

chmod 0600 %{jenkins}/.ssh/id_rsa /root/.ssh/id_rsa
chmod 0644 %{jenkins}/.ssh/id_rsa.pub %{jenkins}/.ssh/known_hosts /root/.ssh/id_rsa.pub /root/.ssh/known_hosts 

# Move over new http configurations
cp -rf %{devenvdir}/httpd/* %{libradir}
cp -rf %{devenvdir}/httpd.conf %{sitedir}/httpd/
cp -rf %{devenvdir}/httpd.conf %{brokerdir}/httpd/
cp -f %{devenvdir}/client.cfg %{devenvdir}/server.cfg /etc/mcollective
cp -f %{devenvdir}/activemq.xml /etc/activemq
mkdir -p %{sitedir}/httpd/logs
mkdir -p %{sitedir}/httpd/run
mkdir -p %{brokerdir}/httpd/logs
mkdir -p %{brokerdir}/httpd/run
ln -s %{sitedir}/public/* %{htmldir}
ln -s /usr/lib64/httpd/modules/ %{sitedir}/httpd/modules
ln -s /usr/lib64/httpd/modules/ %{brokerdir}/httpd/modules

# Ensure /tmp and /var/tmp aren't world usable
#chmod o-rwX /tmp /var/tmp
#setfacl -m u:libra_passenger:rwx /tmp
#setfacl -m u:jenkins:rwx /tmp
#setfacl -m u:apache:rwx /tmp
#setfacl -m u:mysql:rwx /tmp
############# FIXME ############
#### Dirty hack until there's a mcollective fix
chmod o+rwX /tmp /var/tmp

# Jenkins specific setup
usermod -G libra_user jenkins
chown -R jenkins:jenkins /var/lib/jenkins

# Allow Apache to connect to Jenkins port 8081
getsebool httpd_can_network_connect | grep -q -e 'on$' || /usr/sbin/setsebool -P httpd_can_network_connect=on || :

# Allow polyinstantiation to work
getsebool allow_polyinstantiation | grep -q -e 'on$' || /usr/sbin/setsebool -P allow_polyinstantiation=on || :

# Allow httpd to relay
getsebool httpd_can_network_relay | grep -q -e 'on$' || /usr/sbin/setsebool -P httpd_can_network_relay=on || :

# Ensure that V8 in Node.js can compile JS for Rails asset compilation
getsebool httpd_execmem | grep -q -e 'on$' || /usr/sbin/setsebool -P httpd_execmem=on || :

# Add policy for developement environment
cd %{policydir} ; make -f ../devel/Makefile
semodule -l | grep -q dhcpnamedforward || semodule -i dhcpnamedforward.pp
cd


# Increase kernel semaphores to accomodate many httpds
echo "kernel.sem = 250  32000 32  4096" >> /etc/sysctl.conf
sysctl kernel.sem="250  32000 32  4096"

# Move ephemeral port range to accommodate app proxies
echo "net.ipv4.ip_local_port_range = 15000 35530" >> /etc/sysctl.conf
sysctl net.ipv4.ip_local_port_range="15000 35530"

# Increase the connection tracking table size
echo "net.netfilter.nf_conntrack_max = 1048576" >> /etc/sysctl.conf
sysctl net.netfilter.nf_conntrack_max=1048576

# Setup facts
/usr/libexec/mcollective/update_yaml.rb /etc/mcollective/facts.yaml
crontab -u root %{devenvdir}/crontab

# enable disk quotas
/usr/bin/rhc-init-quota
ls -lZ /var/aquota.user  | grep -q var_t && ( quotaoff /var && restorecon /var/aquota.user && quotaon /var )

# Setup swap for devenv
[ -f /.swap ] || ( /bin/dd if=/dev/zero of=/.swap bs=1024 count=1024000
    /sbin/mkswap -f /.swap
    /sbin/swapon /.swap
    echo "/.swap swap   swap    defaults        0 0" >> /etc/fstab
)

# Increase max SSH connections and tries to 40
perl -p -i -e "s/^#MaxSessions .*$/MaxSessions 40/" /etc/ssh/sshd_config
perl -p -i -e "s/^#MaxStartups .*$/MaxStartups 40/" /etc/ssh/sshd_config

# create a submodule repo for the tests
git init /root/submodule_test_repo
pushd /root/submodule_test_repo > /dev/null
    echo Submodule > index
    git add index
    git commit -m 'test'
popd > /dev/null

# Restore permissions
#/sbin/restorecon -R %{_sysconfdir}/qpid/pki
/sbin/restorecon -R %{libradir}
/sbin/restorecon -R /etc/drupal6

# Start services
service iptables restart
service activemq restart
#service qpidd restart
service mcollective start
service libra-datastore configure
service libra-datastore start
service libra-site restart
service libra-broker restart
service jenkins restart
service httpd restart --verbose 2>&1
service sshd restart
chkconfig iptables on
chkconfig named on
#chkconfig qpidd on
chkconfig activemq on
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

# DHCP/DNS Service initialization
service network restart
service named restart

# Drupal Requirements
chkconfig mysqld on
service mysqld start

# Watchman services
chkconfig libra-watchman on || :
service libra-watchman start || :

# Populate mcollective certs
cd /etc/mcollective/ssl/clients
openssl genrsa -out mcollective-private.pem 1024 2> /dev/null
openssl rsa -in mcollective-private.pem -out mcollective-public.pem -outform PEM -pubout 2> /dev/null
chown libra_passenger:root mcollective-private.pem
chmod 460 mcollective-private.pem
cd

# Move static puppet certs in devenv
mkdir -p /var/lib/puppet/ssl/public_keys/
mkdir -p /var/lib/puppet/ssl/private_keys/
cp -f %{devenvdir}/puppet-public.pem /var/lib/puppet/ssl/public_keys/localhost.localdomain.pem
cp -f %{devenvdir}/puppet-private.pem /var/lib/puppet/ssl/private_keys/localhost.localdomain.pem

# Chgrp to wheel for rpm, dmesg, su, and sudo
/bin/chgrp wheel /bin/rpm
/bin/chgrp wheel /bin/dmesg
/bin/chgrp wheel /bin/su
/bin/chgrp wheel /usr/bin/sudo

# Chmod o-x for rpm, dmesg, su, and sudo
/bin/chmod 0750 /bin/rpm
/bin/chmod 0750 /bin/dmesg
/bin/chmod 4750 /bin/su
/bin/chmod 4110 /usr/bin/sudo

# Remove blank passwd for root in shadow
/bin/echo root:\!! | /usr/sbin/chpasswd -e

# Create OpenScap script
cat > /usr/local/bin/openscap.sh << EOF
# Create OpenScap results
/usr/bin/oscap xccdf eval --profile RHEL6-Default --results /var/log/xccdf-results.xml /usr/share/openscap/scap-rhel6-xccdf.xml
#/usr/bin/oscap oval eval --results /var/log/oval-results.xml /usr/share/openscap/scap-rhel6-oval.xml

# Validate the OpenScap results
#/usr/bin/oscap xccdf validate-xml /usr/share/openscap/scap-rhel6-xccdf.xml
#/usr/bin/oscap oval validate-xml /usr/share/openscap/scap-rhel6-oval.xml

# Create OpenScap HTML reports
/usr/bin/oscap xccdf generate report /var/log/xccdf-results.xml > /var/log/report-xccdf.html
#/usr/bin/oscap oval generate report /var/log/oval-results.xml > /var/log/report-oval.html
#/usr/bin/oscap xccdf generate report --oval-template /var/log/oval-results.xml /var/log/xccdf-results.xml > /var/log/report-xccdf-oval.html

# Create rsyslog file from html
/usr/bin/html2text -o /var/log/openscap_rsyslog.txt /var/log/report-xccdf.html
EOF

# Make OpenScap.sh executable
chmod 0750 /usr/local/bin/openscap.sh

# Remove all SUIDs - tkramer - testing in devenv
chmod u-s /usr/bin/staprun
# chmod u-s /usr/bin/chage
chmod u-s /usr/bin/chfn
# chmod u-s /usr/bin/gpasswd
chmod u-s /usr/bin/chsh
chmod u-s /usr/bin/sudoedit
# chmod u-s /usr/bin/passwd
# chmod u-s /usr/bin/crontab
# chmod u-s /usr/bin/at
chmod u-s /usr/bin/sudo
# chmod u-s /usr/bin/pkexec
# chmod u-s /usr/bin/newgrp
# chmod u-s /usr/libexec/polkit-1/polkit-agent-helper-1
# BZ844881 - was chmod 4711
chmod 4710 /usr/libexec/pt_chown
# chmod u-s /usr/libexec/openssh/ssh-keysign
# chmod u-s /usr/sbin/suexec
# chmod u-s /usr/sbin/userhelper
# chmod u-s /usr/sbin/usernetctl
chmod u-s /bin/ping6
chmod u-s /bin/mount
# chmod u-s /bin/su
# chmod u-s /bin/ping
chmod u-s /bin/umount
# chmod u-s /sbin/pam_timestamp_check
chmod u-s /sbin/unix_chkpwd
# chmod u-s /lib64/dbus-1/dbus-daemon-launch-helper

# Remove all SGIDs - tkramer
# chmod g-s /usr/bin/ssh-agent
chmod g-s /usr/bin/wall
# chmod g-s /usr/bin/screen
chmod g-s /usr/bin/locate
# chmod g-s /usr/bin/lockfile
# chmod g-s /usr/bin/write
# chmod g-s /usr/libexec/utempter/utempter
# chmod g-s /usr/sbin/postqueue
# chmod g-s /usr/sbin/postdrop
# chmod g-s /bin/cgexec
# chmod g-s /sbin/netreport

# Make grub.conf readable only to user and group - not other - tkramer
chmod 600 /boot/grub/grub.conf

# Turn off rsyslog compatibility check in OpenScap
sed 's/rule-1125" selected="true/rule-1125" selected="false/' /usr/share/openscap/scap-rhel6-xccdf.xml > /usr/share/openscap/scap-rhel6-xccdf.xml.tmp
mv -f /usr/share/openscap/scap-rhel6-xccdf.xml.tmp /usr/share/openscap/scap-rhel6-xccdf.xml

# Add user nagios_monitor to wheel group for running rpm, dmesg, su, and sudo
/usr/bin/gpasswd -a nagios_monitor wheel

# Populate Drupal Database 
echo "select count(*) from users;" | mysql -u root libra > /dev/null 2>&1 || zcat /usr/share/drupal6/sites/default/openshift-dump.gz | mysql -u root

# Make the webserver use hsts - BZ801848
echo "Header set Strict-Transport-Security \"max-age=15768000\"" > /etc/httpd/conf.d/hsts.conf
echo "Header append Strict-Transport-Security includeSubDomains" >> /etc/httpd/conf.d/hsts.conf

# Create place to drop proxy mod_cache files
mkdir -p /srv/cache/mod_cache
chmod 750 /srv/cache/mod_cache
chown apache:apache /srv/cache/mod_cache

# BZ835097 - remove o-x from tcpdump - was 755
chmod 750 /usr/sbin/tcpdump

# BZ834487 - remove o-x from /etc/stickshift/resource_limit files - was 644
chmod 640 /etc/stickshift/resource_limits.conf.c9
chmod 640 /etc/stickshift/resource_limits.conf.exlarge
chmod 640 /etc/stickshift/resource_limits.conf.high_density
chmod 640 /etc/stickshift/resource_limits.conf.jumbo
chmod 640 /etc/stickshift/resource_limits.conf.large
chmod 640 /etc/stickshift/resource_limits.conf.medium
chmod 640 /etc/stickshift/resource_limits.conf.micro
chmod 640 /etc/stickshift/resource_limits.conf.small
chmod 640 /etc/stickshift/resource_limits.template

# Remove Other rights from iptables-multi - was 755
chmod 750 /sbin/iptables-multi

# Remove Other rights from ip6tables-multi - was 755
chmod 750 /sbin/ip6tables-multi

# Remove Other rights from crontab - was 4755 - BZ856939
chmod 750 /usr/bin/crontab

# Remove Other rights from at - was 4755 - BZ856933
chmod 750 /usr/bin/at

# Fix devenv log file ownership
chown root:libra_user /var/www/stickshift/broker/log/development.log
chown root:libra_user /var/www/stickshift/broker/log/mcollective-client.log
chown root:libra_user /var/www/stickshift/site/log/development.log

## For RKHUNTER to not use tmp any more
# Added nagios_monitor user to match STG and PROD
useradd nagios_monitor
# Change /var/log/rkhunter perms
chown -R root:nagios_monitor /var/log/rkhunter
chmod -R 770 /var/log/rkhunter

# Remove Virtual Consoles from /etc/securetty for OpenScap
sed '/^vc\//d' /etc/securetty > /tmp/no_vc
mv /tmp/no_vc /etc/securetty

# Create Disable Transport for OpenScap check
cat > /etc/modprobe.d/disable_transport.conf << EOF
# Disables the latest transports in RHEL6 for OpenScap checks
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
EOF

# Deploy application templates - fotios
/usr/bin/ruby /usr/lib/stickshift/broker/application_templates/templates/deploy.rb
if [ $? -ne 0 ]
then
  service mongod restart
  service libra-broker restart
  sleep 10
  /usr/bin/ruby /usr/lib/stickshift/broker/application_templates/templates/deploy.rb
fi

%files
%defattr(-,root,root,-)
%attr(0660,-,-) %{brokerdir}/log/mcollective-client.log
%attr(0660,-,-) %{brokerdir}/log/development.log
%attr(0660,-,-) %{sitedir}/log/development.log
%config(noreplace) %{jenkins}/jobs/*/*
%{jenkins}/jobs/sync.rb
%{devenvdir}
%{_initddir}/libra-datastore
%{_initddir}/libra-broker
%{_initddir}/libra-site
%{_initddir}/sauce-connect
%{policydir}/*

%changelog
* Thu Sep 27 2012 Adam Miller <admiller@redhat.com> 0.100.6-1
- stop the nesting of old source build dirs (dmcphers@redhat.com)

* Wed Sep 26 2012 Adam Miller <admiller@redhat.com> 0.100.5-1
- Merge branch 'move_opensource' (ccoleman@redhat.com)
- find_and_build_specs should fail devenv builds if any failure happens
  (ccoleman@redhat.com)
- add origin-dev-tools to li-devenv.sh (dmcphers@redhat.com)
- Copy origin-dev-tools to the remote server during build sync
  (ccoleman@redhat.com)
- Merge branch 'opensource_console_final' (ccoleman@redhat.com)
- synching the job configs in the repo with the actual config in  jenkins
  (abhgupta@redhat.com)
- Httparty rpm available (ccoleman@redhat.com)
- Merge pull request #394 from markllama/devenv-activemq
  (openshift+bot@redhat.com)
- switch from qpid messaging to activemq (mlamouri@redhat.com)
- Force bundle installation of site gems, make selinux enablement correct.  Set
  permissions on site_ruby (ccoleman@redhat.com)
- Merge remote-tracking branch 'origin/master' into opensource_console_final
  (ccoleman@redhat.com)
- Changes necessary to run site in devenv in Ruby 1.9 mode (selinux execmem
  hack, change order site.conf is loaded, and add site_ruby stub for
  LD_LOAD_PATH) (ccoleman@redhat.com)
- Merge branch 'master' into rails32 (ccoleman@redhat.com)
- Merge remote-tracking branch 'origin/master' into opensource
  (ccoleman@redhat.com)
- Prevent builds from running twice (ccoleman@redhat.com)
- Changes to build env to allow multistage builds (ccoleman@redhat.com)

* Mon Sep 24 2012 Adam Miller <admiller@redhat.com> 0.100.4-1
- Modifying jenkins jobs to accommodate build scripts moving to a separate repo
  (abhgupta@redhat.com)
- handle provides when installing requires (dmcphers@redhat.com)

* Mon Sep 24 2012 Adam Miller <admiller@redhat.com> 0.100.3-1
- keep source build folders (dmcphers@redhat.com)

* Thu Sep 20 2012 Adam Miller <admiller@redhat.com> 0.100.2-1
- don't want register/official for test ami (admiller@redhat.com)
- fixed jenkins job xml to reflect change in build call (admiller@redhat.com)
- added libra_ami_test and libra-test repo build scripts (admiller@redhat.com)
- Security - remove other perms from crontab and at for BZ856933 and BZ856939
  (tkramer@redhat.com)
- Change hard-coded references to mongodb-2.2 (rmillner@redhat.com)
- BZ 847906: Enable compression for specific content types.
  (rmillner@redhat.com)

* Wed Sep 12 2012 Adam Miller <admiller@redhat.com> 0.100.1-1
- bump_minor_versions for sprint 18 (admiller@redhat.com)

* Thu Sep 06 2012 Adam Miller <admiller@redhat.com> 0.99.4-1
- Fix for bugz 852216 - zend /sandbox should be root owned if possible.
  (ramr@redhat.com)

* Tue Sep 04 2012 Adam Miller <admiller@redhat.com> 0.99.3-1
- only run 1 set of qe tests since they are proper subsets
  (dmcphers@redhat.com)

* Thu Aug 30 2012 Adam Miller <admiller@redhat.com> 0.99.2-1
- moving test pull requests to its own repo (dmcphers@redhat.com)
- exit on instability (dmcphers@redhat.com)
- fix typo (dmcphers@redhat.com)
- Security - Removed other execute from pt_chown for BZ844881
  (tkramer@redhat.com)
- enfore packages are installed from local for install from source
  (dmcphers@redhat.com)
- Merge pull request #315 from lnader/master (openshift+bot@redhat.com)
- Bug 852139: Disable emails to mailbox. (mpatel@redhat.com)
- Bug 851679 - ssh -R seems to be ignoring the remote bind address
  (lnader@redhat.com)
- Merge pull request #308 from tkramer-rh/dev/tkramer/openscap/run_file_fix
  (openshift+bot@redhat.com)
- syncing pull requests script (dmcphers@redhat.com)
- Security - Made the OpenScap run file look closer to production
  (tkramer@redhat.com)
- reorg broker extended tests (dmcphers@redhat.com)
- enable caching for tests and use nolinks some (dmcphers@redhat.com)
- Merge pull request #297 from tkramer-rh/dev/tkramer/openscap/html2text
  (openshift+bot@redhat.com)
- Security - Add html2text for OpenScap (tkramer@redhat.com)

* Wed Aug 22 2012 Adam Miller <admiller@redhat.com> 0.99.1-1
- bump_minor_versions for sprint 17 (admiller@redhat.com)
- syncing jenkins scripts (dmcphers@redhat.com)

* Wed Aug 22 2012 Adam Miller <admiller@redhat.com> 0.98.10-1
- look at mergeable on sub pull requests before processing
  (dmcphers@redhat.com)

* Tue Aug 21 2012 Adam Miller <admiller@redhat.com> 0.98.9-1
- Merge pull request #277 from lnader/zend (openshift+bot@redhat.com)
- remove now defunct ruby193 yum repo, it merged with li (admiller@redhat.com)
- US2378: Zend Server Cartridge Packaging (lnader@redhat.com)

* Mon Aug 20 2012 Adam Miller <admiller@redhat.com> 0.98.8-1
- add comments to fork ami about tags (dmcphers@redhat.com)
- Change the format for evaluated (dmcphers@redhat.com)
- better output on local merge (dmcphers@redhat.com)
- add devenv number to pull request after it completes (dmcphers@redhat.com)
- use merge instead of patch for testing pull requests (dmcphers@redhat.com)

* Fri Aug 17 2012 Adam Miller <admiller@redhat.com> 0.98.7-1
- Merge pull request #250 from danmcp/master (openshift+bot@redhat.com)
- trying to get some more stability on the initial ami create
  (dmcphers@redhat.com)

* Thu Aug 16 2012 Adam Miller <admiller@redhat.com> 0.98.6-1
- Security - Remove Virtual Terminals from securetty and blacklist transports
  in modprobe.d for OpenScap checks (tkramer@redhat.com)

* Thu Aug 16 2012 Adam Miller <admiller@redhat.com> 0.98.5-1
- Bug 848419 (dmcphers@redhat.com)

* Wed Aug 15 2012 Adam Miller <admiller@redhat.com> 0.98.4-1
- syncing jenkins jobs (dmcphers@redhat.com)

* Tue Aug 14 2012 Adam Miller <admiller@redhat.com> 0.98.3-1
- syncing test pull requests (dmcphers@redhat.com)
- syncing jenkins scripts (dmcphers@redhat.com)
- show build status for finished jobs in logs (dmcphers@redhat.com)
- syncing pull requests script (dmcphers@redhat.com)
- fixing broker extended tests and adding cleanup of previous fork ami test
  flags (dmcphers@redhat.com)
- allow multiple extended tests to be passed (dmcphers@redhat.com)
- mark evaluated for new trigger as well (dmcphers@redhat.com)
- Bug 846555 (dmcphers@redhat.com)
- move template deployment further down and add a retry (dmcphers@redhat.com)
- Merge pull request #212 from danmcp/master (openshift+bot@redhat.com)
- add more retries around validate (dmcphers@redhat.com)
- testing pull requests (dmcphers@redhat.com)

* Thu Aug 09 2012 Adam Miller <admiller@redhat.com> 0.98.2-1
- syncing jenkins config.xml (dmcphers@redhat.com)
- remove libra check from configs (dmcphers@redhat.com)
- allow non trusted users to add cross links as well as long as the trigger is
  added after (dmcphers@redhat.com)
- work around mergeable not being reliable (dmcphers@redhat.com)
- testing pull requests (dmcphers@redhat.com)
- testing pull requests (dmcphers@redhat.com)
- testing pull requests (dmcphers@redhat.com)
- testing pull requests (dmcphers@redhat.com)
- testing pull requests (dmcphers@redhat.com)
- Create sandbox directory with proper selinux policy and manage
  polyinstantiation for it. (rmillner@redhat.com)
- Merge pull request #192 from danmcp/master (openshift+bot@redhat.com)
- make less calls to github (dmcphers@redhat.com)
- added zend mirror repo (lnader@redhat.com)
- don't add eval comment after merge failure (dmcphers@redhat.com)
- don't add eval comment after merge failure (dmcphers@redhat.com)
- be more restrictive about who can commit (dmcphers@redhat.com)
- make sure all the commits will succeed before trying to merge
  (dmcphers@redhat.com)
- Make sure we retry immediately if code was updated mid run
  (dmcphers@redhat.com)
- work around stickshift proxy being dead (dmcphers@redhat.com)
- don't allow multiple instances for merge pull request (dmcphers@redhat.com)
- customize is previous build running (dmcphers@redhat.com)
- make sure build status is upgraded correctly in pull request
  (dmcphers@redhat.com)
- fix merge issue with crankcase repo (dmcphers@redhat.com)
- provide comments in all prereq pull requests (dmcphers@redhat.com)
- testing pull requests (dmcphers@redhat.com)
- allow install from source to work from stage (dmcphers@redhat.com)
- fixing merge conditions (dmcphers@redhat.com)
- add stage testing for pull requests (dmcphers@redhat.com)
- minor cleanup (dmcphers@redhat.com)
- limit cross reference reporting to 1 request (dmcphers@redhat.com)
- handle all globals and not just gemname (dmcphers@redhat.com)
- better error handling on builds (dmcphers@redhat.com)
- add action required processing (dmcphers@redhat.com)
- testing pull requests (dmcphers@redhat.com)
- allow for nil bot comment (dmcphers@redhat.com)
- dont allow merge if updated after comment (dmcphers@redhat.com)
- few renames (dmcphers@redhat.com)
- correct a few errors with cross references (dmcphers@redhat.com)
- disable jenkins config (dmcphers@redhat.com)
- reworking pull request testing (dmcphers@redhat.com)
- update merge pull request script (dmcphers@redhat.com)
- sync merge pull request job (dmcphers@redhat.com)
- add merge method to test pull requests (dmcphers@redhat.com)
- syncing jenkins jobs (dmcphers@redhat.com)

* Thu Aug 02 2012 Adam Miller <admiller@redhat.com> 0.98.1-1
- bump_minor_versions for sprint 16 (admiller@redhat.com)
- jenkins job updates (dmcphers@redhat.com)

* Wed Aug 01 2012 Adam Miller <admiller@redhat.com> 0.97.10-1
- add fork ami creation process and cleanup (dmcphers@redhat.com)

* Tue Jul 31 2012 Adam Miller <admiller@redhat.com> 0.97.9-1
- remove invalid option (dmcphers@redhat.com)

* Mon Jul 30 2012 Dan McPherson <dmcphers@redhat.com> 0.97.8-1
- Allow drupal database to be dropped and recreated (ccoleman@redhat.com)
- Bug 843313 - Max allowed packet preventing new devenv import.
  (ccoleman@redhat.com)
- Merge pull request #140 from tkramer-rh/dev/tkramer/rkhunter/out_of_tmp
  (dmcphers@redhat.com)
- Security - Add nagios_monitor to match other envs and change perms for
  rkhunter log directory (tkramer@redhat.com)

* Fri Jul 27 2012 Dan McPherson <dmcphers@redhat.com> 0.97.7-1
- Merge pull request #137 from rmillner/dev/rmillner/bug/843337
  (mrunalp@gmail.com)
- Printing out the user names was confusing threaddump. (rmillner@redhat.com)
- Merge pull request #133 from mrunalp/bugs/841681 (rmillner@redhat.com)
- Fix for BZ841681. (mpatel@redhat.com)

* Fri Jul 27 2012 Dan McPherson <dmcphers@redhat.com> 0.97.6-1
- update scripts to support peer repos and same level (jhonce@redhat.com)
- Add user nagios_monitor to match other environments (tkramer@redhat.com) 
- Security create root:nagios_monitor perms for /var/log/rkhunter (tkramer@redhat.com)

* Thu Jul 26 2012 Dan McPherson <dmcphers@redhat.com> 0.97.5-1
- fix install from local source for crankcase (dmcphers@redhat.com)
- add requires for rhc-site-static (dmcphers@redhat.com)
- Merge pull request #90 from tdawson/mirror (dmcphers@redhat.com)
- Security - kwoodsons change to pull puppet httpd and nagios_monitor out of
  using PI (tkramer@redhat.com)
- remove the rhel63 repository (tdawson@redhat.com)
- replace mirror.stg and prod with mirror.ops (tdawson@redhat.com)

* Fri Jul 20 2012 Adam Miller <admiller@redhat.com> 0.97.4-1
- Security - fix log file permissions and ownership (tkramer@redhat.com)

* Fri Jul 20 2012 Tim Kramer <tkramer@redhat.com>
- Fix log file permissions and ownership (tkramer@redhat.com)

* Thu Jul 19 2012 Adam Miller <admiller@redhat.com> 0.97.3-1
- switch cucumber reporting to junit put cucumber xml results in one directory
  (jhonce@redhat.com)
- Update Dan's rhc_pull_request build file. (ccoleman@redhat.com)
- Merge remote-tracking branch 'origin/master' into move_os-client-tools_to_rhc
  (ccoleman@redhat.com)
- Merge pull request #88 from ramr/master (smitram@gmail.com)
- Merge pull request #84 from tkramer-rh/dev/tkramer/resource_limits
  (admiller@redhat.com)
- organize tests by team (dmcphers@redhat.com)
- Add fixes to devenv for bugz 840030 - Apache blocks access to /icons. Remove
  these as mod_autoindex has now been turned OFF (see bugz 785050 for more
  details). (ramr@redhat.com)
- add 4 separate extended tasks and remove libra_extended (dmcphers@redhat.com)
- add cleanup for rhc and li pull requests (dmcphers@redhat.com)
- Security - remove Other permissions from resource_limits and iptables-multi
  (tkramer@redhat.com)
- US2531 - Move os-client-tools to rhc (ccoleman@redhat.com)

* Mon Jul 16 2012 Tim Kramer <tkramer@redhat.com>
- BZ834487 - remove reource_limits permissions from Other (tkramer@redhat.com)
- Remove permissions for iptables-multi from Other (tkramer@redhat.com)

* Fri Jul 13 2012 Adam Miller <admiller@redhat.com> 0.97.2-1
- Enable ssl security in mcollective. (mpatel@redhat.com)
- adding template recreation to the devenv sync (admiller@redhat.com)

* Wed Jul 11 2012 Adam Miller <admiller@redhat.com> 0.97.1-1
- bump_minor_versions for sprint 15 (admiller@redhat.com)

* Tue Jul 10 2012 Adam Miller <admiller@redhat.com> 0.96.10-1
- Bug 838800 - Update streamline address in drupal, make no cookies the default
  (ccoleman@redhat.com)
- Bug 838831 - Simplify enable/disable-sso for all teams (ccoleman@redhat.com)

* Mon Jul 09 2012 Dan McPherson <dmcphers@redhat.com> 0.96.9-1
- split up build steps to tag and push first then release (dmcphers@redhat.com)

* Fri Jul 06 2012 Adam Miller <admiller@redhat.com> 0.96.8-1
- Change mcollective security to psk for now. (mpatel@redhat.com)

* Thu Jul 05 2012 Adam Miller <admiller@redhat.com> 0.96.7-1
- Security - mcollective changing to the Puppetlabs preferred encryption SSL
  from AES (tkramer@redhat.com)

* Tue Jul 03 2012 Adam Miller <admiller@redhat.com> 0.96.6-1
- dirty hack until mcollective patch is a viable option, /tmp/ is world
  writeable for now (admiller@redhat.com)

* Tue Jul 03 2012 Adam Miller <admiller@redhat.com> 0.96.5-1
- WIP changes to support mcollective 2.0. (mpatel@redhat.com)

* Mon Jul 02 2012 Adam Miller <admiller@redhat.com> 0.96.4-1
- Merge pull request #13 from jwhonce/test_pull_request (jwhonce@gmail.com)
- Merge pull request #9 from tkramer-rh/dev/tkramer/bug/835097
  (jwhonce@gmail.com)
- fix repo urls (dmcphers@redhat.com)
- Refactor test_pull_requests to support multiple repos (jhonce@redhat.com)
- Security - added BZ835097 and cleaned up old port binding comments
  (tkramer@redhat.com)
- devenv.spec: adding drupal6-media_tudou (ansilva@redhat.com)
- update streamline ip (dmcphers@redhat.com)
- use the official java client repo (dmcphers@redhat.com)

* Tue Jun 26 2012 Tim Kramer <tkramer@redhat.com>
- Added BZ835097 remove other from tcpdump (tkramer@redhat.com)
- Removed old comments on selinux for binding ports (tkramer@redhat.com)

* Sat Jun 23 2012 Dan McPherson <dmcphers@redhat.com> 0.96.3-1
- new package built with tito

* Thu Jun 21 2012 Adam Miller <admiller@redhat.com> 0.96.2-1
- Enable (depend and install) ruby-1.9 cartridge. (ramr@redhat.com)

* Wed Jun 20 2012 Adam Miller <admiller@redhat.com> 0.96.1-1
- bump_minor_versions for sprint 14 (admiller@redhat.com)

* Tue Jun 19 2012 Adam Miller <admiller@redhat.com> 0.95.9-1
- Added pull request id when starting jenkins job (jhonce@redhat.com)

* Mon Jun 18 2012 Adam Miller <admiller@redhat.com> 0.95.8-1
- more 6.3 update bits for mash, li-devenv.sh and build/release
  (admiller@redhat.com)

* Thu Jun 14 2012 Adam Miller <admiller@redhat.com> 0.95.7-1
- li-devenv.sh: fix up the java problems (tdawson@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (admiller@redhat.com)
- enabling libra rhel63 repos for devenv base image build (admiller@redhat.com)
- Enable ruby193 repo. (ramr@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 0.95.6-1
- update libra_ami jenkins config.xml (admiller@redhat.com)

* Tue Jun 12 2012 Adam Miller <admiller@redhat.com> 0.95.5-1
- Changed URL in motd to point to legal (tkramer@redhat.com)

* Mon Jun 11 2012 Adam Miller <admiller@redhat.com> 0.95.4-1
- Added legal login banner to motd and rhcsh (tkramer@redhat.com)
- Security - Added login banner to motd (tkramer@redhat.com)

* Mon Jun 11 2012 Tim Kramer <tkramer@redhat.com>
- added legal banner to motd (tkramer@redhat.com)
- added legal banner to OpenShift shell rhcsh (tkramer@redhat.com)

* Fri Jun 08 2012 Adam Miller <admiller@redhat.com> 0.95.3-1
- added drupal6-openshift-features-community_wiki to devenv
  (admiller@redhat.com)
- US2307 - enable eap6 (bdecoste@gmail.com)

* Mon Jun 04 2012 Adam Miller <admiller@redhat.com> 0.95.2-1
- Update httpd.conf to enable proper logging of keepalive status
  (ccoleman@redhat.com)
- Merge branch 'master' into net_http_persistent (ccoleman@redhat.com)
- test case improvements (dmcphers@redhat.com)
- add variable max run time to instances (dmcphers@redhat.com)
- add libra_extended (dmcphers@redhat.com)
- stop requiring init_repo (dmcphers@redhat.com)
- Merge branch 'master' into net_http_persistent (ccoleman@redhat.com)
- Add keepalive to the devenv (ccoleman@redhat.com)

* Fri Jun 01 2012 Adam Miller <admiller@redhat.com> 0.95.1-1
- bumping spec versions (admiller@redhat.com)

* Thu May 31 2012 Adam Miller <admiller@redhat.com> 0.94.12-1
- fix libra_ami issue (dmcphers@redhat.com)
- Updating pull request script to poll Jenkins (mhicks@redhat.com)

* Wed May 30 2012 Adam Miller <admiller@redhat.com> 0.94.11-1
- Added deploy script to devenv.spec (fotioslindiakos@gmail.com)
- More automatic testing enhancements (mhicks@redhat.com)

* Tue May 29 2012 Adam Miller <admiller@redhat.com> 0.94.10-1
- Adding automatic pull request support (mhicks@redhat.com)
- Security - Moved the disable of binding of ports on the real 10. address from
  devenv.spec to rhc-ip-prep.sh so that it can make it into STG for testing
  (tkramer@redhat.com)
- fix condition keeping jboss from being preinstalled (dmcphers@redhat.com)

* Sun May 27 2012 Dan McPherson <dmcphers@redhat.com> 0.94.9-1
- use ignore packages for the source build as well (dmcphers@redhat.com)
- add base package concept (dmcphers@redhat.com)
- add base package concept (dmcphers@redhat.com)

* Fri May 25 2012 Adam Miller <admiller@redhat.com> 0.94.8-1
- Security - put more sticky permissions back on files to match what is in STG
  05 25 2012 (tkramer@redhat.com)
- li-devenv.sh: adding the rhel63 repo (tdawson@redhat.com)

* Thu May 24 2012 Adam Miller <admiller@redhat.com> 0.94.7-1
- US2307 - removed eap from devenv.spec (bdecoste@gmail.com)
- US2307 (bdecoste@gmail.com)

* Wed May 23 2012 Adam Miller <admiller@redhat.com> 0.94.6-1
- Broke the build (admiller@redhat.com)

* Wed May 23 2012 Adam Miller <admiller@redhat.com> 0.94.5-1
- Security - Added fix for BZ821940 and reverted stickies for screen and ping
  (tkramer@redhat.com)
- Enable hydra RPM for devenv (ccoleman@redhat.com)

* Wed May 23 2012 Tim Kramer <tkramer@redhat.com>
- Prevented sticky bit from being removed from screen and ping like in stg and prod (tkramer@redhat.com)
- Prevent users from binding to real 10. IP - BZ821940 (tkramer@redhat.com)

* Tue May 22 2012 Adam Miller <admiller@redhat.com> 0.94.4-1
- sync jenkins settings with devenv (dmcphers@redhat.com)
- improving jenkins artifacts (dmcphers@redhat.com)
- add webmock to requires of devenv (dmcphers@redhat.com)

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.94.3-1
- 

* Thu May 17 2012 Adam Miller <admiller@redhat.com> 0.94.2-1
- get tests running faster (dmcphers@redhat.com)
- Add rcov to broker and as a dependency for devenv for build & test.
  (rmillner@redhat.com)
- Removed proxy balance from express.conf 05 14 2012 (tkramer@redhat.com)
- mod_cache added to devenv 05 14 2012 (tkramer@redhat.com)
- Add a much improved ideas view and sub pages (ccoleman@redhat.com)
- bypass java SSL issue by passing property jsse.enableSNIExtension=false
  (johnp@redhat.com)

* Mon May 14 2012 Tim Kramer <tkramer@redhat.com>
- Added mod_cache to the proxy server and supporting directory

* Thu May 10 2012 Adam Miller <admiller@redhat.com> 0.94.1-1
- bumping spec versions (admiller@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.93.12-1
- Backup of jenkins jobs to get new libra_coverage. (rmillner@redhat.com)

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.93.11-1
- 

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.93.10-1
- 

* Wed May 09 2012 Adam Miller <admiller@redhat.com> 0.93.9-1
- By default, drupal in the devenv should log notifications instead of emailing
  them (ccoleman@redhat.com)

* Tue May 08 2012 Adam Miller <admiller@redhat.com> 0.93.8-1
- fixed make-certs.txt to have the correct hostname for qpid servers
  (twiest@redhat.com)
- SSO enable for drupal had errors (ccoleman@redhat.com)

* Mon May 07 2012 Adam Miller <admiller@redhat.com> 0.93.7-1
- Restart httpd after adding users. (ccoleman@redhat.com)
- Merge events recent changes and user profile into code. (ccoleman@redhat.com)
- Ensure that recent_activity_report gets installed in devenv and update
  revert-features to include community_wiki (ccoleman@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Enable journaling for mongo on devenv (rpenta@redhat.com)
- added localrepo support for the tito builds to install only rhc-devenv
  (admiller@redhat.com)
- devenv.spec: add drupal6-geoip module (ansilva@redhat.com)
- Security - removed gpgcheck since they are only signed for Production  05 04
  2012 (tkramer@redhat.com)
- Create a simple script that allows easy export of features from Drupal to
  disk and back to a devenv. (ccoleman@redhat.com)
- Fix devenv build break - use #!/bin/bash (ccoleman@redhat.com)
- Add drupal revert and setup steps to be easier to run (ccoleman@redhat.com)
- Package rename python(3.2 -> 2.6), ruby(1.1 -> 1.8) (kraman@gmail.com)
- Security - removed the log perms changes (tkramer@redhat.com)
- Security - Removed OpenScap crontab entry since it conflicted with the facts
  creation. (tkramer@redhat.com)
- Security - Removed chmod of rhc-watchman.pid - needs to be in rhc-node RPM
  05 02 2012 (tkramer@redhat.com)
- Security - changed OpenScap rsyslog compatibility check 1125 - tkramer 04 01
  2012 (tkramer@redhat.com)
- Added gpgcheck to li.repo and epel.repo testing in devenv
  (tkramer@redhat.com)
- Security - removed chmod on tmp passenger files for now 05 01 2012
  (tkramer@redhat.com)
- Security added more checks for SGIDs - tkramer 05 01 2012
  (tkramer@redhat.com)
- Security - removed SGIDs and SUIDs from all for devenv testing - removed
  other read from log files and grub.conf - tkramer 05 01 2012
  (tkramer@redhat.com)
- SGID and SUID removal place holder for devenv testing  04 30 2012
  (tkramer@redhat.com)
- Fixed gpasswd error   04 30 2012 (tkramer@redhat.com)
- OpenScap - Added OpenScap run script and crontab entry Also removed blank
  passwd for root in shadow   04 30 2012 (tkramer@redhat.com)
- Discovered problem where the benchmark task was using the libra_ami
  workspace.  Also, clean out rhc logs from workspace to prevent accumulation
  of large amounts of data. (rmillner@redhat.com)
- devenv.spec: adding drupal6-wysiwyg (ansilva@redhat.com)
- Run backup of jenkins configs after changing benchmark job.
  (rmillner@redhat.com)
- li-devenv.sh: added ruby193 repo, disabled (tdawson@redhat.com)

* Wed May 02 2012 Tim Kramer <tkramer@redhat.com> 0.93.6-1
- Removed the chmod of rhc-watchman.pid.  This needs to happen in the rhc-node rpm 05 02 2012

* Tue May 01 2012 Tim Kramer <tkramer@redhat.com> 0.93.5-1
- Removed add SGIDs and SUIDs for testing 05 01 2012
- Removed other readable to log files 05 01 2012
- Removed other readable to grub 05 01 2012
- Make li.repo and epel.repo to use gpgcheck - testing in devenv 05 01 2012
- Remove rsyslog compatibility check out of OpenScap test 1125 05 01 2012

* Mon Apr 30 2012 Tim Kramer <tkramer@redhat.com> 0.93.4-1
- Dropped in place holder for removal off all SGIDs and SUIDs  04 30 2012

* Mon Apr 30 2012 Tim Kramer <tkramer@redhat.com> 0.93.3-1
- Security - Added OpenScap cron tab entry and run script 04 30 2012
- Security - Removed blank root passwd in shadow 04 30 2012

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.93.2-1
- Security - added info to change log for RKHunter and OpenSCAP  04 26 2012
  (tkramer@redhat.com)
- Security - Added two sections for security tools RKHunter and OpenSCAP 04 26
  2012 (tkramer@redhat.com)

* Thu Apr 26 2012 Tim Kramer <tkramer@redhat.com)
- Added security requirements for RKHunter and OpenSCAP

* Thu Apr 26 2012 Adam Miller <admiller@redhat.com> 0.93.1-1
- bumping spec versions (admiller@redhat.com)
- Update enable-modules.sh (ccoleman@redhat.com)

* Wed Apr 25 2012 Adam Miller <admiller@redhat.com> 0.92.12-1
- Bug 815173 - Set header in drupal to force IE edge mode in devenv.   Ensure
  that status messages won't be shown for N-1 compat with site   Update
  copyright colors to be black background   Update copyright date
  (ccoleman@redhat.com)

* Tue Apr 24 2012 Adam Miller <admiller@redhat.com> 0.92.11-1
- make sure og_actions is enabled for druple (johnp@redhat.com)
- Bug 815668 (dmcphers@redhat.com)
- devenv.spec adding drupal6-path_redirect (ansilva@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.92.10-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (tdawson@redhat.com)
- li-devenv.sh: changed epel servers to be real names (tdawson@redhat.com)
- li-devenv.sh: fixed epel repo basearch (tdawson@redhat.com)
- li-devenv.sh: fixed epel repo (tdawson@redhat.com)
- li-devenv.sh: Changed epel to point to our mirror (tdawson@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.92.9-1
- dont reuse the same vars! (dmcphers@redhat.com)
- devenv.spec add drupal6-media_youku (ansilva@redhat.com)

* Mon Apr 23 2012 Adam Miller <admiller@redhat.com> 0.92.8-1
- adding deploy key to ami (dmcphers@redhat.com)

* Sat Apr 21 2012 Dan McPherson <dmcphers@redhat.com> 0.92.7-1
- moving to github prep (dmcphers@redhat.com)
- Update jenkins backup (rmillner@redhat.com)
- Drupal updates based on latest changes (ccoleman@redhat.com)
- Add all required modules (ccoleman@redhat.com)
- Minor tweaks to benchmark job. (rmillner@redhat.com)
- Update the Jenkins job list for the remaining new tasks and re-run sync.
  (rmillner@redhat.com)
- Add libra_ami_benchmark job and run the jenkins sync. (rmillner@redhat.com)
- use m1.large for libra_check (dmcphers@redhat.com)

* Wed Apr 18 2012 Dan McPherson <dmcphers@redhat.com> 0.92.6-1
- Add geshi to enablement script (ccoleman@redhat.com)

* Wed Apr 18 2012 Dan McPherson <dmcphers@redhat.com> 0.92.5-1
- BZ785050 Removed mod_autoindex and supporting bits    tkramer  04 18 2012
  (tkramer@redhat.com)

* Wed Apr 18 2012 Adam Miller <admiller@redhat.com> 0.92.4-1
- Fixed mod_autoindex 04 18 2012 (tkramer@redhat.com)
- BZ785050 Removed mod_autoindex and options  04 17 2012  second change
  (tkramer@redhat.com)
- Removed mod_autoindex for  BZ785050 - testing in devenv (tkramer@redhat.com)
- Merge remote-tracking branch 'origin/master' into dev/fotios/login
  (ccoleman@redhat.com)
- Added some speed improvements to devenv rpm (mmcgrath@redhat.com)
- attempt to fix /var issues (mmcgrath@redhat.com)
- Merge branch 'master' into dev/fotios/login (ccoleman@redhat.com)
- Ensure staging settings are syntactically correct (ccoleman@redhat.com)
- Switch to /community (ccoleman@redhat.com)
- Move Drupal to /community (ccoleman@redhat.com)
- Automatic commit of package [rhc-devenv] release [0.91.8-1].
  (mmcgrath@redhat.com)
- Add required drupal modules to master (ccoleman@redhat.com)
- Syncing jobs for jenkins (mmcgrath@redhat.com)
- Bug fix to get li-cleanup-util working. (ramr@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.92.3-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Fix li-users-delete-util script (rpenta@redhat.com)

* Thu Apr 12 2012 Mike McGrath <mmcgrath@redhat.com> 0.92.2-1
- release bump for tag uniqueness (mmcgrath@redhat.com)

* Wed Apr 11 2012 Adam Miller <admiller@redhat.com> 0.91.10-1
- two more drupal6-modules to devenv.spec (ansilva@redhat.com)
- Added wiki module dependencies for drupal6 (ansilva@redhat.com)

* Wed Apr 11 2012 Anderson Silva <ansilva@redhat.com> 0.91.9-1
- Added wiki module dependencies for drupal6 (ansilva@redhat.com)
* Mon Apr 09 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.8-1
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Merge branch 'master' of li-master:/srv/git/li (ramr@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (mmcgrath@redhat.com)
- Add required drupal modules to master (ccoleman@redhat.com)
- Syncing jobs for jenkins (mmcgrath@redhat.com)
- Bug fix to get li-cleanup-util working. (ramr@redhat.com)
- Merge remote-tracking branch 'origin/master' (kraman@gmail.com)
- devenv/iptables: set the connlimit for port 80 and 443 to match what's in STG
  / PROD per mmcgrath (twiest@redhat.com)
- Merge remote-tracking branch 'origin/master' into dev/kraman/US2048
  (kraman@gmail.com)
- Tweaked the version number (tkramer@redhat.com)
- devenv - Added hsts to Apache - Apr 5 2012 (tkramer@redhat.com)
- Merge remote-tracking branch 'origin/master' (kraman@gmail.com)
- Merge remote-tracking branch 'origin/master' (kraman@gmail.com)
- Fixing dependencies for python, ruby, diy in devenv spec (kraman@gmail.com)
- Merge remote-tracking branch 'origin/master' (kraman@gmail.com)
- Automatic commit of package [rhc-devenv] release [0.91.2-1].
  (kraman@gmail.com)
- Updating dependencies to match new package names (kraman@gmail.com)

* Thu Apr 05 2012 Tim Kramer <tkramer@redhat.com> 0.91.7-1
- Added hsts to Apache for Bugzilla 801848

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.6-1
- Add a simple drupal setup script that makes it easy to get a few common
  operations completed on a local env. (ccoleman@redhat.com)
- Make default devenv drupal settings be server neutral, with SSO disabled
  enable-sso.sh should enable SSO for drupal (ccoleman@redhat.com)

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.5-1
- misc/devenv/devenv.spec: Forgot raw->diy (whearn@redhat.com)

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.4-1
- misc/devenv/devenv.spec: Missed some renamed packages (whearn@redhat.com)

* Tue Apr 03 2012 Mike McGrath <mmcgrath@redhat.com> 0.91.3-1
- Merge branch 'master' of git:/srv/git/li (whearn@redhat.com)
- misc/devenv/devenv.spec - Updated to reflect new package names
  (whearn@redhat.com)
- Modify passengerprestart URL to warm up the rails apps in the devenv
  (ccoleman@redhat.com)
- devenv: adding drupal6-* (ansilva@redhat.com)
- devenv.spec master merge (ansilva@redhat.com)
- fix conflict (ansilva@redhat.com)
- instead of chmod 777 /tmp, using setfacl for apache and mysql
  (ansilva@redhat.com)
- fix permission on development.rb (ansilva@redhat.com)
- added enable-sso.sh script and tweak on /tmp (ansilva@redhat.com)
- adding htaccess file for drupal and bind mysql to 127.0.0.1
  (ansilva@redhat.com)
- post processing for drupal mysql dependencies (ansilva@redhat.com)
- added small note to devenv.spec about mysql work around (ansilva@redhat.com)
- added new rpm for devenv mysql dump handling (ansilva@redhat.com)
- Revert "add mysql user to namespace.d exception" (ansilva@redhat.com)
- add mysql user to namespace.d exception (ansilva@redhat.com)
- fix devenv.spec typo (ansilva@redhat.com)
- update devenv.spec for drupal6 (ansilva@redhat.com)
- update devenv with drupal6 (ansilva@redhat.com)

* Mon Apr 02 2012 Krishna Raman <kraman@gmail.com> 0.91.2-1
- Updating dependencies to match new package names (kraman@gmail.com)

* Mon Apr 2 2012 Anderson Silva <ansilva@redhat.com> 0.91.1-1
- add drupal6 (ansilva@redhat.com)

* Sat Mar 31 2012 Dan McPherson <dmcphers@redhat.com> 0.90.1-1
- bump spec numbers (dmcphers@redhat.com)

* Thu Mar 29 2012 Dan McPherson <dmcphers@redhat.com> 0.89.5-1
- remove old sdk_check (dmcphers@redhat.com)

* Wed Mar 28 2012 Dan McPherson <dmcphers@redhat.com> 0.89.4-1
- Scaling commands are really expensive. Ex: jboss takes 3:30 to scale.
  Increase the broker timeout so that they can show successful completion.
  (rmillner@redhat.com)

* Tue Mar 27 2012 Dan McPherson <dmcphers@redhat.com> 0.89.3-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- added clean up utility (lnader@redhat.com)

* Mon Mar 26 2012 Dan McPherson <dmcphers@redhat.com> 0.89.2-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (lnader@redhat.com)
- Broker and site in devenv should use RackBaseURI and be relative to content
  Remove broker/site app_scope (ccoleman@redhat.com)
- US1876 (lnader@redhat.com)

* Sat Mar 17 2012 Dan McPherson <dmcphers@redhat.com> 0.89.1-1
- bump spec numbers (dmcphers@redhat.com)
- use proper comments in named.conf (markllama@redhat.com)
- rndc control requires TWO config files: rndc.conf and rndc.key
  (markllama@redhat.com)
- let rndc key auto-generate (mlamouri@redhat.com)
- added real rndc.key (mlamouri@redhat.com)
- correctly name default rndc key file (mlamouri@redhat.com)

* Fri Mar 09 2012 Dan McPherson <dmcphers@redhat.com> 0.88.2-1
- Updates for getting devenv running (kraman@gmail.com)
- Renaming Cloud-SDK -> StickShift (kraman@gmail.com)
- remove old comment (mlamouri@redhat.com)
- misc/devenv/li-devenv.sh: updated libra repos to point to new machines
  (tdawson@redhat.com)
- fixed forwarding and removed unneeded experiments with hints
  (mlamouri@redhat.com)
- dont forward FIRST, forward ONLY (mlamouri@redhat.com)
- added SOA to the hints (mlamouri@redhat.com)
- re-insert localhost in nameserver list (mlamouri@redhat.com)
- derive from DHCP response instead of query (mlamouri@redhat.com)
- added upstream hints (mlamouri@redhat.com)

* Fri Mar 02 2012 Dan McPherson <dmcphers@redhat.com> 0.88.1-1
- bump spec numbers (dmcphers@redhat.com)
- add install_from_local_source (dmcphers@redhat.com)
- bypass local named again (mlamouri@redhat.com)
- ok, try this again: local named active and in-line (markllama@redhat.com)
- reverted default use of local named again (markllama@redhat.com)
- trying again to enable local named (mlamouri@redhat.com)
- dont go straight to root to recurse
  (mlamouri@blade14.cloud.lab.eng.bos.redhat.com)

* Wed Feb 29 2012 Dan McPherson <dmcphers@redhat.com> 0.87.8-1
- move submodule create to devenv.spec (dmcphers@redhat.com)

* Tue Feb 28 2012 Dan McPherson <dmcphers@redhat.com> 0.87.7-1
- allow named to getattr on the forwarders file too (mlamouri@redhat.com)
- dnsdomainname still doesnt work with local named (mlamouri@redhat.com)
- removed temp comment and added reference to dhcpnamedforward SELinux policy
  requirement (mlamouri@redhat.com)
- Merge remote-tracking branch 'origin/master' (mlamouri@redhat.com)
- re-enable local DNS (mlamouri@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.6-1
- Merge remote-tracking branch 'origin/master' (mlamouri@redhat.com)
- re-enable lookup recursion (mlamouri@redhat.com)

* Mon Feb 27 2012 Dan McPherson <dmcphers@redhat.com> 0.87.5-1
- Merge remote-tracking branch 'origin/master' (mlamouri@redhat.com)
- commented resolver prepend to bypass local DNS (mlamouri@redhat.com)
- disabled dnssec: it interferes with forwarding EC2 internal requests
  (mlamouri@redhat.com)
- add logic for killing old verifiers (dmcphers@redhat.com)
- Merge remote-tracking branch 'origin/master' (mlamouri@redhat.com)
- disabled recursion to allow correct resolution of ec2 internals
  (mlamouri@redhat.com)
- Fixed path of log file. (mpatel@redhat.com)
- enable named, restart network service to initialize forwarding
  (mlamouri@redhat.com)

* Sat Feb 25 2012 Dan McPherson <dmcphers@redhat.com> 0.87.4-1
- Adds rhc-last-access to cron. (mpatel@redhat.com)
- Merge remote-tracking branch 'origin/master' (mlamouri@redhat.com)
- named listens on 953 as well for rndc silence (mlamouri@redhat.com)
- corrected %%policydir reference in %%post (mlamouri@redhat.com)
- add files entry for policy sources (mlamouri@redhat.com)
- add build code to copy policy files (mlamouri@redhat.com)
- add code to compile and install policy (mlamouri@redhat.com)
- renaming jbossas7 (dmcphers@redhat.com)
- added policy source to allow local DNS server (mlamouri@redhat.com)
- create tito tmp.  seems to be an issue with the new tito
  (dmcphers@redhat.com)
- allow execute of hooks (mlamouri@redhat.com)
- invert named restart condition (mlamouri@redhat.com)
- added rndc config for named status and control (mlamouri@redhat.com)
- Adding httpd.conf file (mmcgrath@redhat.com)
- Merge remote-tracking branch 'origin/master' (mlamouri@redhat.com)
- added a script to update named forwarders on dhcp renew (mlamouri@redhat.com)
- uncommented forwarders (mlamouri@redhat.com)
- li-devenv.sh: removed extra testing output (tdawson@redhat.com)
- li-devenv.sh: fixed my variable in the repo (tdawson@redhat.com)
- li-devenv.sh: added some testing to look at stuff (tdawson@redhat.com)
- li-devenv.sh: install 32 bit java before anything else, do extra yum
  (tdawson@redhat.com)
- li-devenv.sh: added the 32 bit RHUI repo (tdawson@redhat.com)
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li
  (tdawson@redhat.com)
- li-devenv.sh: removed all 32 bit java stuff (tdawson@redhat.com)
- Merge remote-tracking branch 'origin/master' (mlamouri@redhat.com)
- recursion allows proper next-step lookup for non-authoritative zones in the
  local domain (mlamouri@redhat.com)
- li-devenv.sh: install 32 bit java before anything else (tdawson@redhat.com)
- li-devenv.sh: added the 32 bit RHUI repo (tdawson@redhat.com)

* Wed Feb 22 2012 Dan McPherson <dmcphers@redhat.com> 0.87.3-1
- disable named for now (dmcphers@redhat.com)
- added devenv modifications for BIND dns testing (mlamouri@redhat.com)
- switch epel rpm (dmcphers@redhat.com)

* Mon Feb 20 2012 Dan McPherson <dmcphers@redhat.com> 0.87.2-1
- fix calls to update_yaml to actually do something (dmcphers@redhat.com)

* Thu Feb 16 2012 Dan McPherson <dmcphers@redhat.com> 0.87.1-1
- bump spec numbers (dmcphers@redhat.com)

* Wed Feb 15 2012 Dan McPherson <dmcphers@redhat.com> 0.86.6-1
- switch builds to use new official flag (dmcphers@redhat.com)

* Wed Feb 15 2012 Dan McPherson <dmcphers@redhat.com> 0.86.5-1
- Port ranges incorrect (rmillner@redhat.com)

* Tue Feb 14 2012 Dan McPherson <dmcphers@redhat.com> 0.86.4-1
- allow many node devenv setup (dmcphers@redhat.com)
- change exclude_web to include_web (dmcphers@redhat.com)
- working on sauce tests stability (dmcphers@redhat.com)
- With the proxy and balancer, we're using a lot more TCP connections.
  Increase netfilter's connection tracking table size to compensate.
  (rmillner@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.3-1
- start Watchman services (jhonce@redhat.com)

* Mon Feb 13 2012 Dan McPherson <dmcphers@redhat.com> 0.86.2-1
- move the selinux logic out of abstract carts entirely (dmcphers@redhat.com)
- Add Node.js dependency to the devenv spec. (ramr@redhat.com)
- more abstracting out selinux (dmcphers@redhat.com)
- parameterize ami verifies (dmcphers@redhat.com)
- pulling in haproxy to devenv (mmcgrath@redhat.com)
- Dev environment gets new input rule for port proxy range
  (rmillner@redhat.com)
- test without launching a new instance (dmcphers@redhat.com)
- dynamically process BuildRequires (dmcphers@redhat.com)

* Fri Feb 03 2012 Dan McPherson <dmcphers@redhat.com> 0.86.1-1
- bump spec numbers (dmcphers@redhat.com)
- mongodb: user libra willl have access to openshift_broker_dev db (not an
  admin user any more) (rpenta@redhat.com)

* Thu Feb 02 2012 Dan McPherson <dmcphers@redhat.com> 0.85.15-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- add --namespace to li-users-delete-util helper script (rpenta@redhat.com)

* Wed Feb 01 2012 Dan McPherson <dmcphers@redhat.com> 0.85.14-1
- Merge branch 'master' of git1.ops.rhcloud.com:/srv/git/li (rpenta@redhat.com)
- Helper script to delete all users and their domains in the current devenv
  instance (rpenta@redhat.com)

* Tue Jan 31 2012 Dan McPherson <dmcphers@redhat.com> 0.85.13-1
- Don't kill all mongod processes -- only the libra-datastore one.
  (ramr@redhat.com)

* Tue Jan 31 2012 Dan McPherson <dmcphers@redhat.com> 0.85.12-1
- - Handle both ReplicaSet and normal mongodb connection - Retry for 30 secs
  (60 times in 0.5 sec frequency) in case of mongo connection failure. - On
  devenv, configure/start mongod with replicaSet = 1 (rpenta@redhat.com)

* Mon Jan 30 2012 Dan McPherson <dmcphers@redhat.com> 0.85.11-1
- Revert changes to development.log in site,broker,devenv spec
  (aboone@redhat.com)
- Reduce number of rubygem dependencies in site build (aboone@redhat.com)

* Sat Jan 28 2012 Dan McPherson <dmcphers@redhat.com> 0.85.10-1
- Site build - don't use bundler, install all gems via RPM (aboone@redhat.com)

* Fri Jan 27 2012 Dan McPherson <dmcphers@redhat.com> 0.85.9-1
- build fixes (dmcphers@redhat.com)
- Re-enabling 127.0.0.1 ban (mmcgrath@redhat.com)
- Add back rubygem-rake and rubygem-rspec dependencies for devenv
  (aboone@redhat.com)
- Fix for 532e0e8, also properly set permissions on logs (aboone@redhat.com)
- Remove therubyracer gem dependency, "js" is already being used
  (aboone@redhat.com)
- Since site is touching the development.log during build, remove touches from
  devenv.spec (aboone@redhat.com)
- Provide barista dependencies at site build time (aboone@redhat.com)
- Add BuildRequires: rubygem-crack for site spec (aboone@redhat.com)
- add requires (dmcphers@redhat.com)
- config cleanup for ticket (dmcphers@redhat.com)
- Bug 784809 (dmcphers@redhat.com)
- devenv.spec - changed chgrp before chmod to apply proper rights to su sudo
  dmesg and rpm 01 25 2012 (tkramer@redhat.com)
- cleanup (dmcphers@redhat.com)
- cleanup (dmcphers@redhat.com)
- add rake and rspec to build prereqs (dmcphers@redhat.com)
- cleanup (dmcphers@redhat.com)
- Added rhc-cartridge-cron to list of packages for devenv. (ramr@redhat.com)
- allow install from source plus some districts changes (dmcphers@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.8-1
- resolve merge conflicts (rpenta@redhat.com)
- Expose internal mongo datastore through rock-mongo UI (rpenta@redhat.com)

* Tue Jan 24 2012 Dan McPherson <dmcphers@redhat.com> 0.85.7-1
- add pam-devel (dmcphers@redhat.com)
- devenv.spec changed comment typo in chmod section 01 24 2012
  (tkramer@redhat.com)
- devenv.spec Added changes for sudo rpm su and dmesg.  Also added nagios
  monitor to wheel group  01 23 2012 (tkramer@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Merge branch 'master' of ssh://git1.ops.rhcloud.com/srv/git/li
  (rmillner@redhat.com)
- Don't overlap range. (rmillner@redhat.com)
- US1371, Move the ephemeral port range down to clear room for proxy.
  (rmillner@redhat.com)

* Mon Jan 23 2012 Tim Kramer <tkramer@redhat.com> 0.85.6-1
- Fixed the o-x permissions on sudo rpm su and dmesg
- Added nagios_monitor to wheel so that it can run sudo rpm su and dmesg

* Fri Jan 20 2012 Mike McGrath <mmcgrath@redhat.com> 0.85.5-1
- more rack/ruby replacements (mmcgrath@redhat.com)
