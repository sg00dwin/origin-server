%define htmldir %{_localstatedir}/www/html
%define libradir %{_localstatedir}/www/openshift
%define brokerdir %{_localstatedir}/www/openshift/broker
%define sitedir %{_localstatedir}/www/openshift/site
%define devenvdir %{_sysconfdir}/openshift/devenv
%define jenkins %{_sharedstatedir}/jenkins
%define policydir %{_datadir}/selinux/packages

Summary:   Dependencies for OpenShift development
Name:      rhc-devenv
Version: 1.1.3
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
Requires:  openshift-origin-cartridge-php-5.3
Requires:  openshift-origin-cartridge-python-2.6
Requires:  openshift-origin-cartridge-ruby-1.8
Requires:  openshift-origin-cartridge-jbossas-7
Requires:  openshift-origin-cartridge-jbosseap-6.0
Requires:  openshift-origin-cartridge-switchyard-0.6
Requires:  openshift-origin-cartridge-jbossews-1.0
Requires:  openshift-origin-cartridge-perl-5.10
Requires:  openshift-origin-cartridge-mysql-5.1
Requires:  openshift-origin-cartridge-phpmyadmin-3.4
Requires:  openshift-origin-cartridge-jenkins-1.4
Requires:  openshift-origin-cartridge-diy-0.1
Requires:  openshift-origin-cartridge-jenkins-client-1.4
Requires:  openshift-origin-cartridge-metrics-0.1
Requires:  openshift-origin-cartridge-mongodb-2.2
Requires:  openshift-origin-cartridge-phpmoadmin-1.0
Requires:  openshift-origin-cartridge-rockmongo-1.1
Requires:  openshift-origin-cartridge-10gen-mms-agent-0.1
Requires:  openshift-origin-cartridge-postgresql-8.4
Requires:  openshift-origin-cartridge-cron-1.4
Requires:  openshift-origin-cartridge-haproxy-1.4
Requires:  openshift-origin-cartridge-nodejs-0.6
Requires:  openshift-origin-cartridge-ruby-1.9-scl
Requires:  openshift-origin-cartridge-zend-5.6
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
Requires:  ruby193-build
Requires:  ruby193-rubygems-devel
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
Requires:  drupal6-node_import
Requires:  drupal6-og
Requires:  drupal6-openshift-custom_forms
Requires:  drupal6-openshift-features-application_quickstarts
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
Requires:  drupal6-views_datasource
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

# Marking installation as a devenv
mkdir -p %{buildroot}/etc/openshift
touch %{buildroot}/etc/openshift/development

%clean
rm -rf %{buildroot}

%post
# Setup node.conf for the devenv
cp -f /etc/openshift/node.conf.libra /etc/openshift/node.conf
restorecon /etc/openshift/node.conf || :

# Install the Sauce Labs gems
gem install sauce --no-rdoc --no-ri
gem install zip --no-rdoc --no-ri

# Install hub for automatic pull request testing
gem install hub --no-rdoc --no-ri

# Install gems for sprint_status_script
gem install rally_rest_api --no-rdoc --no-ri
gem install kramdown --no-rdoc --no-ri

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

# Allow misc Openshift related Apache options
getsebool httpd_run_stickshift | grep -q -e 'on$' || /usr/sbin/setsebool -P httpd_run_stickshift=on || :

# Allow Apache to connect to Jenkins port 8081
getsebool httpd_can_network_connect | grep -q -e 'on$' || /usr/sbin/setsebool -P httpd_can_network_connect=on || :

# Allow polyinstantiation to work
getsebool allow_polyinstantiation | grep -q -e 'on$' || /usr/sbin/setsebool -P allow_polyinstantiation=on || :

# Allow httpd to relay
getsebool httpd_can_network_relay | grep -q -e 'on$' || /usr/sbin/setsebool -P httpd_can_network_relay=on || :

# Ensure that V8 in Node.js can compile JS for Rails asset compilation
getsebool httpd_execmem | grep -q -e 'on$' || /usr/sbin/setsebool -P httpd_execmem=on || :

# Allow httpd to verify dns records
getsebool httpd_verify_dns | grep -q -e 'on$' || /usr/sbin/setsebool -P httpd_verify_dns=on || :
 
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
service rhc-datastore configure
service rhc-datastore start
service rhc-site restart
service rhc-broker restart
service jenkins restart
service httpd restart --verbose 2>&1
service sshd restart
chkconfig iptables on
chkconfig named on
#chkconfig qpidd on
chkconfig activemq on
chkconfig mcollective on
chkconfig rhc-datastore on
chkconfig rhc-site on
chkconfig rhc-broker on
chkconfig jenkins on
chkconfig httpd on

# CGroup services
service cgconfig start
service cgred start
service openshift-cgroups start
service libra-tc start
chkconfig cgconfig on
chkconfig cgred on
chkconfig openshift-cgroups on
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
# BZ817670 - /usr/sbin/usernetctl was 4755
chmod 4750 /usr/sbin/usernetctl
# BZ817668 - /usr/sbin/userhelper was 4711
chmod 4710 /usr/sbin/userhelper
# BZ873080 - /sbin/pam_timestamp_check was 4755
chmod 4750 /sbin/pam_timestamp_check
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

# BZ834487 - remove o-x from /etc/openshift/resource_limit files - was 644
chmod 640 /etc/openshift/resource_limits.conf.c9
chmod 640 /etc/openshift/resource_limits.conf.exlarge
chmod 640 /etc/openshift/resource_limits.conf.high_density
chmod 640 /etc/openshift/resource_limits.conf.jumbo
chmod 640 /etc/openshift/resource_limits.conf.large
chmod 640 /etc/openshift/resource_limits.conf.medium
chmod 640 /etc/openshift/resource_limits.conf.micro
chmod 640 /etc/openshift/resource_limits.conf.small
chmod 640 /etc/openshift/resource_limits.template

# Remove Other rights from iptables-multi - was 755
chmod 750 /sbin/iptables-multi

# Remove Other rights from ip6tables-multi - was 755
chmod 750 /sbin/ip6tables-multi

# Remove Other rights from crontab - was 4755 - BZ856939
chmod 750 /usr/bin/crontab

# Remove Other rights from at - was 4755 - BZ856933
chmod 750 /usr/bin/at

# Fix devenv log file ownership
chown root:libra_user /var/www/openshift/broker/log/development.log
chown root:libra_user /var/www/openshift/broker/log/mcollective-client.log
chown root:libra_user /var/www/openshift/site/log/development.log

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

# Create a known test user with medium-sized gears - nhr
# This must be done before the deployment of application templates!
echo "Creating named test user"
sleep_time=10
for i in {1..5}
do
  cd /var/www/openshift/broker && bundle exec rails runner 'test_user=CloudUser.new("user_with_multiple_gear_sizes@test.com"); test_user.save();'
  if [ $? -ne 0 ]
  then
    if [ $i -eq 5 ]
    then
      echo "Named test user could not be created."
      break
    fi
    service mongod restart
    sleep $sleep_time
    sleep_time=$(expr $sleep_time + 10)
    echo "Retrying....."
  else
    /usr/sbin/oo-admin-ctl-user -l user_with_multiple_gear_sizes@test.com --addgearsize medium
    echo "Named test user created."
    break
  fi
done

#/usr/bin/ruby /usr/lib/openshift/broker/application_templates/templates/deploy.rb
#if [ $? -ne 0 ]
#then
#  service mongod restart
#  service rhc-broker restart
#  sleep 10
#  /usr/bin/ruby /usr/lib/openshift/broker/application_templates/templates/deploy.rb
#fi

# Hack to resolve parser error
# See https://github.com/cucumber/gherkin/issues/182
if [ -f /usr/lib/ruby/gems/1.8/gems/gherkin-2.2.4/lib/gherkin/i18n.rb ]
then
  sed -i 's/listener, force_ruby=false/listener, force_ruby=true/' \
      /usr/lib/ruby/gems/1.8/gems/gherkin-2.2.4/lib/gherkin/i18n.rb
fi

# BZ864807 - clean up redundant assets to prevent JS oddities
#            in rails development mode.
cd /var/www/openshift/site && /usr/bin/scl enable ruby193 "rake assets:clean"

%files
%defattr(-,root,root,-)
%attr(0660,-,-) %{brokerdir}/log/mcollective-client.log
%attr(0660,-,-) %{brokerdir}/log/development.log
%attr(0660,-,-) %{sitedir}/log/development.log
%config(noreplace) %{jenkins}/jobs/*/*
%{jenkins}/jobs/sync_up.rb
%{jenkins}/jobs/sync_down.rb
%{devenvdir}
%{_initddir}/rhc-datastore
%{_initddir}/rhc-broker
%{_initddir}/rhc-site
%{_initddir}/sauce-connect
%{policydir}/*
/etc/openshift/development

%triggerin -- rubygem-openshift-origin-node
cp -f /etc/openshift/node.conf.libra /etc/openshift/node.conf
restorecon /etc/openshift/node.conf || :
/sbin/service libra-data restart > /dev/null 2>&1 || :

%changelog
* Mon Nov 12 2012 Adam Miller <admiller@redhat.com> 1.1.3-1
- Missed a few locations to update the UID. (rmillner@redhat.com)
- trying again (bdecoste@gmail.com)

* Thu Nov 08 2012 Adam Miller <admiller@redhat.com> 1.1.2-1
- Increase the table sizes to cover 15000 nodes in dev and prod.
  (rmillner@redhat.com)
- Fix for Bug 873543 (jhonce@redhat.com)
- Security change perms for BZ817670_BZ817668 BZ873080 (tkramer@redhat.com)
- Security - remove other perms from userhelper and usernetctl -
  BZ817670_BZ817668 (tkramer@redhat.com)
- syncing jenkins jobs (dmcphers@redhat.com)
- syncing jenkins jobs (dmcphers@redhat.com)
- adding enterprise-1.0 repo (dmcphers@redhat.com)

* Thu Nov 01 2012 Adam Miller <admiller@redhat.com> 1.1.1-1
- bump_minor_versions for sprint 20 (admiller@redhat.com)

* Thu Nov 01 2012 Adam Miller <admiller@redhat.com> 1.0.5-1
- Security - create a polyinstantiated /dev/shm 5M in size (tkramer@redhat.com)

* Thu Nov 01 2012 Adam Miller <admiller@redhat.com> 1.0.4-1
- moving rhc-accept-devenv to devenv rpm (dmcphers@redhat.com)
- Merge pull request #555 from pravisankar/dev/ravi/bug/869748
  (openshift+bot@redhat.com)
- Update selinux-policy package, enable httpd_verify_dns (rpenta@redhat.com)

* Wed Oct 31 2012 Adam Miller <admiller@redhat.com> 1.0.3-1
- move broker/node utils to /usr/sbin/ everywhere (admiller@redhat.com)

* Tue Oct 30 2012 Adam Miller <admiller@redhat.com> 1.0.2-1
- fix request params for dev tools repo (dmcphers@redhat.com)

* Tue Oct 30 2012 Adam Miller <admiller@redhat.com> 1.0.1-1
- bumping specs to at least 1.0.0 (dmcphers@redhat.com)

* Mon Oct 29 2012 Adam Miller <admiller@redhat.com> 0.100.19-1
- making onprem scripts more like the other devenvs - work in progress
  (dmcphers@redhat.com)
- various cleanup (dmcphers@redhat.com)
- syncing jenkins jobs (dmcphers@redhat.com)
- adding retries and debugging around creating test users and templates
  (dmcphers@redhat.com)
- Merge pull request #532 from kraman/global_broker_config
  (openshift+bot@redhat.com)
- add an extra yum update after adding li.repo (dmcphers@redhat.com)
- Converted dynect and streamline plugins to rails engines Moved plugin config
  into /etc/openshift/plugins.d Moved broker global conf to
  /etc/openshift/broker.conf Modified broker and plugins to loca *-dev.conf
  files when in development environment Mofied broker to switch to dev
  environment with /etc/openshift/development flag is present
  (kraman@gmail.com)
- syncing jenkins configs (dmcphers@redhat.com)

* Fri Oct 26 2012 Adam Miller <admiller@redhat.com> 0.100.18-1
- rename li-devenv.sh to setup-li-repos.sh to relect what it does
  (dmcphers@redhat.com)
- fix key location (dmcphers@redhat.com)
- moving logic to only run as part of base ami (dmcphers@redhat.com)
- break addtl jenkins params into groups (dmcphers@redhat.com)
- move remaining logic out of li-devenv.sh (dmcphers@redhat.com)
- more prep to handle multiple repos from jenkins jobs (dmcphers@redhat.com)
- more work to make repos configurable (dmcphers@redhat.com)

* Wed Oct 24 2012 Adam Miller <admiller@redhat.com> 0.100.17-1
- syncing jenkins config (dmcphers@redhat.com)
- syncing with latest jenkins configs (dmcphers@redhat.com)
- Making build tools more configurable (dmcphers@redhat.com)

* Mon Oct 22 2012 Adam Miller <admiller@redhat.com> 0.100.16-1
- Added commands to remove redundant JS assets from devenv (nhr@redhat.com)

* Fri Oct 19 2012 Adam Miller <admiller@redhat.com> 0.100.15-1
- Merge pull request #502 from tdawson/tdawson/i386repo
  (openshift+bot@redhat.com)
- changes for i386 java-1.7.0-openjdk (tdawson@redhat.com)
- adding drupal6-node_import package to devenv.spec and adding to
  enable_modules.sh drush script (ansilva@redhat.com)

* Thu Oct 18 2012 Adam Miller <admiller@redhat.com> 0.100.14-1
- Bug 867671 (dmcphers@redhat.com)
- Fixes for scripts moved to origin-server (kraman@gmail.com)
- Polydirs moved to Origin.  The /sandbox directory stays in Hosted for now.
  (rmillner@redhat.com)
- Consolidate boolean setting with devenv. (rmillner@redhat.com)
- Bugs from testing. (rmillner@redhat.com)
- Move SELinux to Origin and use new policy definition. (rmillner@redhat.com)

* Tue Oct 16 2012 Adam Miller <admiller@redhat.com> 0.100.13-1
- Added sprint_status_report jenkins jobs (fotios@redhat.com)

* Mon Oct 15 2012 Adam Miller <admiller@redhat.com> 0.100.12-1
- sync jenkins jobs to update libra_ami_test to install_from_source
  (admiller@redhat.com)
- Added logic to create a named test user on devenv (hripps@redhat.com)
- added ews (bdecoste@gmail.com)
- Set the correct ip address mongod binds on in devenv. (ramr@redhat.com)
- Revert "REVERT "Fix to start mongodb w/ replica sets + use the base mongod
  init script."" (ramr@redhat.com)
- REVERT "Fix to start mongodb w/ replica sets + use the base mongod init
  script." (admiller@redhat.com)
- Fix to start mongodb w/ replica sets + use the base mongod init script.
  (ramr@redhat.com)
- fixing libra_ami_stage and libra_ami_verify_stage (abhgupta@redhat.com)
- added rh-amazon-rhui-client-jbews1 for tomcat cart (admiller@redhat.com)

* Mon Oct 08 2012 Adam Miller <admiller@redhat.com> 0.100.11-1
- Merge pull request #450 from
  smarterclayton/add_ruby193_rubygems_devel_to_devenv
  (openshift+bot@redhat.com)
- fix spec (dmcphers@redhat.com)
- renaming crankcase -> origin-server (dmcphers@redhat.com)
- Fixing renames, paths, configs and cleaning up old packages. Adding
  obsoletes. (kraman@gmail.com)
- Add ruby193-rubygems-devel to devenv.spec so that sync will always pass
  (ccoleman@redhat.com)
- get multinode setup working with activemq (dmcphers@redhat.com)
- Merge pull request #446 from pmorie/bugs/859541 (openshift+bot@redhat.com)
- Merge pull request #447 from maxamillion/dev/admiller/enable_rhui_jboss
  (openshift+bot@redhat.com)
- BZ859541: Move manipulation of stickshift-node.conf from rhc-node spec to
  devenv spec (pmorie@gmail.com)
- enable jboss rhui repo in devenv (admiller@redhat.com)

* Thu Oct 04 2012 Adam Miller <admiller@redhat.com> 0.100.10-1
- Merge pull request #438 from brenton/remove_os_scripts2
  (openshift+bot@redhat.com)
- Merging in the latest from master (bleanhar@redhat.com)
- The openshift-origin-broker-util packages provides the newly renamed admin
  scripts (bleanhar@redhat.com)
