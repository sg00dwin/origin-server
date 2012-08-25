lang en_US.UTF-8
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --enforcing
firewall --enabled --service=mdns
xconfig --startxonboot
part / --size 6000  --fstype ext4 --ondisk sda
services --enabled=network,sshd --disabled=NetworkManager
bootloader --append="biosdevname=0"

repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
#repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
repo --name=updates --baseurl=file:///build/update_repo
repo --name=brew --baseurl=file:///build/brew
repo --name=stickshift --baseurl=file:///build/tito/rpms/fc16/x86_64
repo --name=passenger --baseurl=http://passenger.stealthymonkeys.com/fedora/$releasever/$basearch

%packages
@base-x

@base
-smartmontools

@core

@fonts
-lohit-assamese-fonts
-lohit-bengali-fonts
-lohit-devanagari-fonts
-lohit-gujarati-fonts
-lohit-kannada-fonts
-lohit-oriya-fonts
-lohit-punjabi-fonts
-lohit-telugu-fonts
-paktype-naqsh-fonts
-paktype-tehreer-fonts
-paratype-pt-sans-fonts
-sil-abyssinica-fonts
-sil-padauk-fonts
-smc-meera-fonts
-stix-fonts
-thai-scalable-waree-fonts
-un-core-dotum-fonts
-wqy-zenhei-fonts

@input-methods
-ibus-pinyin-db-open-phrase
-ibus-pinyin-db-android

@admin-tools
@hardware-support

@graphical-internet
@gnome-desktop
-evolution                   
-libreoffice-core            
-libreoffice-presenter-screen
-libreoffice-impress         
-libreoffice-graphicfilter   
-libreoffice-draw            
-libreoffice-pdfimport       
-libreoffice-langpack-en     
-libreoffice-calc            
-libreoffice-math            
-libreoffice-writer          
-libreoffice-xsltfilter      
-evolution-NetworkManager    
-evolution-help    
-ibus-gnome3
vim
emacs

# Explicitly specified here:
# <notting> walters: because otherwise dependency loops cause yum issues.
kernel

# This was added a while ago, I think it falls into the category of
# "Diagnosis/recovery tool useful from a Live OS image".  Leaving this untouched
# for now.
memtest86+

# The point of a live image is to install
anaconda
isomd5sum
# grub-efi and grub2 and efibootmgr so anaconda can use the right one on install. 
grub-efi
grub2
efibootmgr

# fpaste is very useful for debugging and very small
fpaste

# FIXME; apparently the glibc maintainers dislike this, but it got put into the
# desktop image at some point.  We won't touch this one for now.
nss-mdns

# rebranding
-fedora-logos
-fedora-release
-fedora-release-notes
generic-release
generic-logos
generic-release-notes

#stickshift
tig
git
rhc
stickshift-broker

cartridge-10gen-mms-agent-0.1
cartridge-cron-1.4
#cartridge-haproxy-1.4
cartridge-jbossas-7
cartridge-jbosseap-6.0
cartridge-jenkins-1.4
cartridge-jenkins-client-1.4
cartridge-mongodb-2.0
cartridge-mysql-5.1
cartridge-nodejs-0.6
cartridge-perl-5.10
cartridge-php-5.3
#cartridge-phpmoadmin-1.0
cartridge-phpmyadmin-3.4
#cartridge-postgresql-8.4
cartridge-ruby-1.8
cartridge-diy-0.1
#cartridge-rockmongo-1.1
cartridge-python-2.6

rubygem-swingshift-mongo-plugin
rubygem-uplift-bind-plugin
rubygem-gearchanger-oddjob-plugin

mongodb 
mongodb-server

%end

%post
cat > /etc/rc.d/init.d/livesys << EOF
#!/bin/bash
#
# live: Init script for live image
#
# chkconfig: 345 00 99
# description: Init script for live image.

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" liveimg || [ "\$1" != "start" ]; then
    exit 0
fi

if [ -e /.liveimg-configured ] ; then
    configdone=1
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

touch /.liveimg-configured

# Make sure we don't mangle the hardware clock on shutdown
ln -sf /dev/null /etc/systemd/system/hwclock-save.service

# mount live image
if [ -b \`readlink -f /dev/live\` ]; then
   mkdir -p /mnt/live
   mount -o ro /dev/live /mnt/live 2>/dev/null || mount /dev/live /mnt/live
fi

livedir="LiveOS"
for arg in \`cat /proc/cmdline\` ; do
  if [ "\${arg##live_dir=}" != "\${arg}" ]; then
    livedir=\${arg##live_dir=}
    return
  fi
done

# enable swaps unless requested otherwise
swaps=\`blkid -t TYPE=swap -o device\`
if ! strstr "\`cat /proc/cmdline\`" noswap && [ -n "\$swaps" ] ; then
  for s in \$swaps ; do
    action "Enabling swap partition \$s" swapon \$s
  done
fi
if ! strstr "\`cat /proc/cmdline\`" noswap && [ -f /mnt/live/\${livedir}/swap.img ] ; then
  action "Enabling swap file" swapon /mnt/live/\${livedir}/swap.img
fi

mountPersistentHome() {
  # support label/uuid
  if [ "\${homedev##LABEL=}" != "\${homedev}" -o "\${homedev##UUID=}" != "\${homedev}" ]; then
    homedev=\`/sbin/blkid -o device -t "\$homedev"\`
  fi

  # if we're given a file rather than a blockdev, loopback it
  if [ "\${homedev##mtd}" != "\${homedev}" ]; then
    # mtd devs don't have a block device but get magic-mounted with -t jffs2
    mountopts="-t jffs2"
  elif [ ! -b "\$homedev" ]; then
    loopdev=\`losetup -f\`
    if [ "\${homedev##/mnt/live}" != "\${homedev}" ]; then
      action "Remounting live store r/w" mount -o remount,rw /mnt/live
    fi
    losetup \$loopdev \$homedev
    homedev=\$loopdev
  fi

  # if it's encrypted, we need to unlock it
  if [ "\$(/sbin/blkid -s TYPE -o value \$homedev 2>/dev/null)" = "crypto_LUKS" ]; then
    echo
    echo "Setting up encrypted /home device"
    plymouth ask-for-password --command="cryptsetup luksOpen \$homedev EncHome"
    homedev=/dev/mapper/EncHome
  fi

  # and finally do the mount
  mount \$mountopts \$homedev /home
  # if we have /home under what's passed for persistent home, then
  # we should make that the real /home.  useful for mtd device on olpc
  if [ -d /home/home ]; then mount --bind /home/home /home ; fi
  [ -x /sbin/restorecon ] && /sbin/restorecon /home
  if [ -d /home/liveuser ]; then USERADDARGS="-M" ; fi
}

findPersistentHome() {
  for arg in \`cat /proc/cmdline\` ; do
    if [ "\${arg##persistenthome=}" != "\${arg}" ]; then
      homedev=\${arg##persistenthome=}
      return
    fi
  done
}

if strstr "\`cat /proc/cmdline\`" persistenthome= ; then
  findPersistentHome
elif [ -e /mnt/live/\${livedir}/home.img ]; then
  homedev=/mnt/live/\${livedir}/home.img
fi

# if we have a persistent /home, then we want to go ahead and mount it
if ! strstr "\`cat /proc/cmdline\`" nopersistenthome && [ -n "\$homedev" ] ; then
  action "Mounting persistent /home" mountPersistentHome
fi

# make it so that we don't do writing to the overlay for things which
# are just tmpdirs/caches
mount -t tmpfs -o mode=0755 varcacheyum /var/cache/yum
mount -t tmpfs tmp /tmp
mount -t tmpfs vartmp /var/tmp
[ -x /sbin/restorecon ] && /sbin/restorecon /var/cache/yum /tmp /var/tmp >/dev/null 2>&1

if [ -n "\$configdone" ]; then
  exit 0
fi

# add fedora user with no passwd
action "Adding live user" useradd \$USERADDARGS -c "Live System User" liveuser
passwd -d liveuser > /dev/null

# turn off firstboot for livecd boots
systemctl --no-reload disable firstboot-text.service 2> /dev/null || :
systemctl --no-reload disable firstboot-graphical.service 2> /dev/null || :
systemctl stop firstboot-text.service 2> /dev/null || :
systemctl stop firstboot-graphical.service 2> /dev/null || :

# don't use prelink on a running live image
sed -i 's/PRELINKING=yes/PRELINKING=no/' /etc/sysconfig/prelink &>/dev/null || :

# turn off mdmonitor by default
systemctl --no-reload disable mdmonitor.service 2> /dev/null || :
systemctl --no-reload disable mdmonitor-takeover.service 2> /dev/null || :
systemctl stop mdmonitor.service 2> /dev/null || :
systemctl stop mdmonitor-takeover.service 2> /dev/null || :

# don't enable the gnome-settings-daemon packagekit plugin
gsettings set org.gnome.settings-daemon.plugins.updates active 'false' || :

# don't start cron/at as they tend to spawn things which are
# disk intensive that are painful on a live image
systemctl --no-reload disable crond.service 2> /dev/null || :
systemctl --no-reload disable atd.service 2> /dev/null || :
systemctl stop crond.service 2> /dev/null || :
systemctl stop atd.service 2> /dev/null || :

# and hack so that we eject the cd on shutdown if we're using a CD...
if strstr "\`cat /proc/cmdline\`" CDLABEL= ; then
  cat >> /sbin/halt.local << FOE
#!/bin/bash
# XXX: This often gets stuck during shutdown because /etc/init.d/halt
#      (or something else still running) wants to read files from the block\
#      device that was ejected.  Disable for now.  Bug #531924
# we want to eject the cd on halt, but let's also try to avoid
# io errors due to not being able to get files...
#cat /sbin/halt > /dev/null
#cat /sbin/reboot > /dev/null
#/usr/sbin/eject -p -m \$(readlink -f /dev/live) >/dev/null 2>&1
#echo "Please remove the CD from your drive and press Enter to finish restarting"
#read -t 30 < /dev/console
FOE
chmod +x /sbin/halt.local
fi

EOF

# bah, hal starts way too late
cat > /etc/rc.d/init.d/livesys-late << EOF
#!/bin/bash
#
# live: Late init script for live image
#
# chkconfig: 345 99 01
# description: Late init script for live image.

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" liveimg || [ "\$1" != "start" ] || [ -e /.liveimg-late-configured ] ; then
    exit 0
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

touch /.liveimg-late-configured

# read some variables out of /proc/cmdline
for o in \`cat /proc/cmdline\` ; do
    case \$o in
    ks=*)
        ks="--kickstart=\${o#ks=}"
        ;;
    xdriver=*)
        xdriver="\${o#xdriver=}"
        ;;
    esac
done

# if liveinst or textinst is given, start anaconda
if strstr "\`cat /proc/cmdline\`" liveinst ; then
   plymouth --quit
   /usr/sbin/liveinst \$ks
fi
if strstr "\`cat /proc/cmdline\`" textinst ; then
   plymouth --quit
   /usr/sbin/liveinst --text \$ks
fi

# configure X, allowing user to override xdriver
if [ -n "\$xdriver" ]; then
   cat > /etc/X11/xorg.conf.d/00-xdriver.conf <<FOE
Section "Device"
	Identifier	"Videocard0"
	Driver	"\$xdriver"
EndSection
FOE
fi

EOF

chmod 755 /etc/rc.d/init.d/livesys
/sbin/restorecon /etc/rc.d/init.d/livesys
/sbin/chkconfig --add livesys

chmod 755 /etc/rc.d/init.d/livesys-late
/sbin/restorecon /etc/rc.d/init.d/livesys-late
/sbin/chkconfig --add livesys-late

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora
echo "Packages within this LiveCD"
rpm -qa
# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*

# go ahead and pre-make the man -k cache (#455968)
/usr/bin/mandb

# save a little bit of space at least...
rm -f /boot/initramfs*
# make sure there aren't core files lying around
rm -f /core*

# convince readahead not to collect
# FIXME: for systemd

%end

%post --nochroot
cp $INSTALL_ROOT/usr/share/doc/*-release-*/GPL $LIVE_ROOT/GPL

# only works on x86, x86_64
if [ "$(uname -i)" = "i386" -o "$(uname -i)" = "x86_64" ]; then
  if [ ! -d $LIVE_ROOT/LiveOS ]; then mkdir -p $LIVE_ROOT/LiveOS ; fi
  cp /usr/bin/livecd-iso-to-disk $LIVE_ROOT/LiveOS
fi
%end

%post

# cleanup rpmdb to allow non-matching host and chroot RPM versions
rm -f /var/lib/rpm/__db*

echo "Starting Kickstart Post"
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cat >> /etc/rc.d/init.d/livesys << EOF
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# disable screensaver locking
cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.override << FOE
[org.gnome.desktop.screensaver]
lock-enabled=false
FOE

# and hide the lock screen option
cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.lockdown.gschema.override << FOE
[org.gnome.desktop.lockdown]
disable-lock-screen=true
FOE

# disable updates plugin
cat >> /usr/share/glib-2.0/schemas/org.gnome.settings-daemon.plugins.updates.gschema.override << FOE
[org.gnome.settings-daemon.plugins.updates]
active=false
FOE

# make the installer show up
if [ -f /usr/share/applications/liveinst.desktop ]; then
  # Show harddisk install in shell dash
  sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop ""
  # need to move it to anaconda.desktop to make shell happy
  mv /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop

  cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override << FOE
[org.gnome.shell]
favorite-apps=['mozilla-firefox.desktop', 'evolution.desktop', 'empathy.desktop', 'rhythmbox.desktop', 'shotwell.desktop', 'openoffice.org-writer.desktop', 'nautilus.desktop', 'anaconda.desktop']
FOE

fi

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login
cat >> /etc/gdm/custom.conf << FOE
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
FOE

mkdir -p /home/liveuser/.config/autostart
cat <<FOE > /home/liveuser/.config/autostart/openshift.desktop
[Desktop Entry]
Type=Application
Exec=/usr/bin/firefox file:///var/www/html/getting_started.html
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Openshift
Name=Openshift
Comment[en_US]=Openshift
Comment=Openshift
FOE
cat <<FOE > /home/liveuser/.config/autostart/terminal.desktop
[Desktop Entry]
Type=Application
Exec=/usr/bin/gnome-terminal
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Terminal
Name=Terminal
Comment[en_US]=Terminal
Comment=Terminal
FOE
chown -R liveuser:liveuser /home/liveuser
chown -R liveuser:liveuser /home/liveuser/.config

cat <<FOE > /home/liveuser/SOURCES.txt
A complete machine-readable copy of the source code corresponding to
certain portions of the accompanying software is available from Red
Hat on request. To obtain such source code, send a check or money
order in the amount of US$10.00 along with a copy of this offer to:

Legal Affairs 
c/o Richard Fontana
Red Hat, Inc.
314 Littleton Road
Westford, MA 01886 USA

Please provide an email address and a telephone number so that we may
contact you should we have any questions concerning fulfillment of
your order. This offer is open to any third party in receipt of this
information and shall expire three years following the date of the
most recent distribution of the accompanying software by Red Hat.

Corresponding source packages for components of this software that are
taken from Fedora 16 are also available at
http://koji.fedoraproject.org/koji/.
FOE

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

EOF

cat <<EOF > /etc/rc.d/init.d/livesys-late-openshift
#!/bin/bash
#
# live: Late init script for live image
#
# chkconfig: 345 99 01
# description: Late init script for configuring image

echo "initialize mongodb"
service mongod start

#wait for "[initandlisten] waiting for connections"
WAIT=1
while [ 1 -eq \$WAIT ] ; do /bin/fgrep "[initandlisten] waiting for connections" /var/log/mongodb/mongodb.log && WAIT=\$? ; echo "Waiting for mongo to initialize ...\n" ; tail -5 /var/log/mongodb/mongodb.log ; sleep 1 ; done
/usr/bin/mongo localhost/stickshift_broker_dev --eval "db.addUser(\"stickshift\", \"mooo\")"

mkdir -p /home/liveuser/.openshift/
echo "libra_server=localhost" > /home/liveuser/.openshift/express.conf
chown liveuser:liveuser /home/liveuser/.openshift/express.conf
chmod og+rw /home/liveuser/.openshift/express.conf

# get the first resolver from /etc/resolv.conf
FORWARDER=\`grep nameserver /etc/resolv.conf | head -1 | cut -d' ' -f2\`

# insert localhost before the first nameserver line
sed -i -e '1,/nameserver/ { /nameserver/ i\
nameserver 127.0.0.1
}' /etc/resolv.conf

# Set up the initial forwarder
echo "forwarders { \${FORWARDER} ; } ;" > /var/named/forwarders.conf

# set SELinux label for forwarders file
/sbin/restorecon -v /var/named/forwarders.conf

grep -l NM_CONTROLLED /etc/sysconfig/network-scripts/ifcfg-* | xargs perl -p -i -e '/NM_CONTROLLED/ && s/yes/no/i'
su -c "/usr/bin/ss-register-user -u admin -p admin"


su -c "/usr/bin/ss-register-user -u admin -p admin"
EOF

echo "Final setup"

# Increase kernel semaphores to accomodate many httpds
echo "kernel.sem = 250  32000 32  4096" >> /etc/sysctl.conf
sysctl kernel.sem="250  32000 32  4096"

# Move ephemeral port range to accommodate app proxies
echo "net.ipv4.ip_local_port_range = 15000 35530" >> /etc/sysctl.conf
sysctl net.ipv4.ip_local_port_range="15000 35530"

# Increase the connection tracking table size
echo "net.netfilter.nf_conntrack_max = 1048576" >> /etc/sysctl.conf
sysctl net.netfilter.nf_conntrack_max=1048576

# Increase max SSH connections and tries to 40
perl -p -i -e "s/^#MaxSessions .*$/MaxSessions 40/" /etc/ssh/sshd_config
perl -p -i -e "s/^#MaxStartups .*$/MaxStartups 40/" /etc/ssh/sshd_config

chkconfig mongod on
perl -p -i -e "s/^#auth = .*$/auth = true/" /etc/mongodb.conf

echo "setup stickshift plugins in broker"
sed -i -e "s/^# Add plugin gems here/# Add plugin gems here\ngem 'swingshift-mongo-plugin'\ngem 'uplift-bind-plugin'\ngem 'gearchanger-oddjob-plugin'\n/" /var/www/stickshift/broker/Gemfile

echo "setup bind-plugin selinux policy"
mkdir -p /usr/share/selinux/packages/rubygem-uplift-bind-plugin
cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/dhcpnamedforward.* /usr/share/selinux/packages/rubygem-uplift-bind-plugin/
pushd /usr/share/selinux/packages/rubygem-uplift-bind-plugin/ && make -f /usr/share/selinux/devel/Makefile ; popd
semodule -i /usr/share/selinux/packages/rubygem-uplift-bind-plugin/dhcpnamedforward.pp

# preserve the existing named config
if [ ! -f /etc/named.conf.orig ]
then
  mv /etc/named.conf /etc/named.conf.orig
fi

# install the local server named
cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/named.conf /etc/named.conf
chown root:named /etc/named.conf
/usr/bin/chcon system_u:object_r:named_conf_t:s0 -v /etc/named.conf

echo "copy example.com. keys in place for bind"
mkdir -p /var/named
cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/Kexample.com.* /var/named
KEY=$( grep Key: /var/named/Kexample.com.*.private | cut -d' ' -f 2 )

cat <<EOF > /var/named/example.com.key
  key example.com {
    algorithm HMAC-MD5 ;
    secret "${KEY}" ;
  } ;
EOF

/sbin/restorecon -v /var/named/example.com.key

mkdir -p /var/named/dynamic
cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/example.com.db /var/named/dynamic/
/sbin/restorecon -v -R /var/named/dynamic/

echo "Enable and start local named"
/sbin/chkconfig named on
/sbin/chkconfig NetworkManager off
/sbin/chkconfig network on

echo "Setup dhcp update hooks"
cat <<EOF > /etc/dhcp/dhclient.conf
# prepend localhost for DNS lookup in dev and test
prepend domain-name-servers 127.0.0.1 ;
EOF

cp /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/dhclient-up-hooks /etc/dhcp/dhclient-up-hooks

echo "Set resource limits"
cat <<EOF > /etc/stickshift/resource_limits.conf
#
# Apache bandwidth limit
# 
apache_bandwidth="all 500000"
apache_maxconnection="all 20"
apache_bandwidtherror="510"
#
# Apache rotatelogs tuning
rotatelogs_interval=86400
rotatelogs_format="-%Y%m%d-%H%M%S-%Z"
EOF

sed -i -e "s/^# Add plugin gems here/# Add plugin gems here\ngem 'swingshift-mongo-plugin'\ngem 'uplift-bind-plugin'\ngem 'gearchanger-oddjob-plugin'\n/" /var/www/stickshift/broker/Gemfile
pushd /var/www/stickshift/broker/ && rm -f Gemfile.lock && bundle show && chown apache:apache Gemfile.lock && popd

mkdir -p /var/www/stickshift/broker/config/environments/plugin-config


echo "require File.expand_path('../plugin-config/swingshift-mongo-plugin.rb', __FILE__)" >> /var/www/stickshift/broker/config/environments/development.rb
cat <<EOF > /var/www/stickshift/broker/config/environments/plugin-config/swingshift-mongo-plugin.rb
Broker::Application.configure do
  config.auth = {
    :salt => "ClWqe5zKtEW4CJEMyjzQ",
    
    # Replica set example: [[<host-1>, <port-1>], [<host-2>, <port-2>], ...]
    :mongo_replica_sets => false,
    :mongo_host_port => ["localhost", 27017],
  
    :mongo_user => "stickshift",
    :mongo_password => "mooo",
    :mongo_db => "stickshift_broker_dev",
    :mongo_collection => "auth_user"
  }
end
EOF

cp -n /usr/lib/ruby/gems/1.8/gems/uplift-bind-plugin-*/doc/examples/Kexample.com.* /var/named
KEY=$( grep Key: /var/named/Kexample.com.*.private | cut -d' ' -f 2 )
echo "require File.expand_path('../plugin-config/uplift-bind-plugin.rb', __FILE__)" >> /var/www/stickshift/broker/config/environments/development.rb
cat <<EOF > /var/www/stickshift/broker/config/environments/plugin-config/uplift-bind-plugin.rb
Broker::Application.configure do
  config.dns = {
    :server => "127.0.0.1",
    :port => 53,
    :keyname => "example.com",
    :keyvalue => "${KEY}",
    :zone => "example.com"
  }
end
EOF

chkconfig stickshift-broker on
chkconfig httpd on

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
EOF

# Setup swap for VM
[ -f /.swap ] || ( /bin/dd if=/dev/zero of=/.swap bs=1024 count=1024000
    /sbin/mkswap -f /.swap
    /sbin/swapon /.swap
    echo "/.swap swap   swap    defaults        0 0" >> /etc/fstab
)

echo 'AcceptEnv GIT_SSH' >> /etc/ssh/sshd_config
ln -s /usr/bin/sssh /usr/bin/rhcsh
chkconfig oddjobd on
chmod 755 /etc/rc.d/init.d/livesys-late-openshift
/sbin/restorecon /etc/rc.d/init.d/livesys-late-openshift
/sbin/chkconfig --add livesys-late-openshift

mkdir -p /home/liveuser/.config/autostart
chown -R liveuser:liveuser /home/liveuser/.config
echo <<EOF > /home/liveuser/.config/autostart/openshift.desktop
[Desktop Entry]
Type=Application
Exec=/usr/bin/firefox http://www.openshift.com
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Openshift
Name=Openshift
Comment[en_US]=Openshift
Comment=Openshift
EOF

%end

%post
cat <<EOF > /var/www/html/getting_started.html
<!DOCTYPE html>
<html class=" js flexbox canvas canvastext webgl no-touch geolocation postmessage websqldatabase indexeddb hashchange history draganddrop websockets rgba hsla multiplebgs backgroundsize borderimage borderradius boxshadow textshadow opacity cssanimations csscolumns cssgradients cssreflections csstransforms csstransforms3d csstransitions fontface localstorage sessionstorage webworkers applicationcache" lang="en"><!--<![endif]--><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta charset="utf-8">
<meta content="IE=edge,chrome=1" http-equiv="X-UA-Compatible">
<title>
OpenShift by Red Hat
|
Get Started
</title>
<meta content="" name="description">
<meta content="" name="author">
<meta content="width=device-width, initial-scale=1.0" name="viewport">
<link href="https://openshift.redhat.com/app/images/favicon-32.png" rel="shortcut icon" type="image/png">
<link href="https://openshift.redhat.com/app/stylesheets/overpass.css" media="all" rel="stylesheet" type="text/css">
<script src="https://openshift.redhat.com/app/javascripts/modernizr.min.js" type="text/javascript"></script>
<link href="https://openshift.redhat.com/app/stylesheets/common.css" media="all" rel="stylesheet" type="text/css">
<link href="https://openshift.redhat.com/app/stylesheets/site.css" media="all" rel="stylesheet" type="text/css">

<style></style></head>
<body class="product getting_started hasGoogleVoiceExt">

<header>
<div class="section-top" id="top">
<div class="container">
<div class="pull-left">
</div>
<div class="pull-right login">
</div>
</div>
</div>
<nav class="section-nav lift-counter" id="nav">
<div class="navbar">
	<div class="messaging messaging-home">
		<div class="container">
			<div class="primary headline">
			</div>
			<div class="secondary">
			</div>
		</div>
	</div>
</div>
</nav>

</header>
<div class="section-striped" id="content">
<div class="container">
<div class="row-content">
<div class="row row-flush-right">
<div class="column-content lift-less grid-wrapper">
<div class="span12 span-flush-right">

<h1 class="ribbon">About this Openshift Origin LiveCD</h1>
<section id="intro">
OpenShift Origin contains the open-source components that power OpenShift. Source code and documentation for these components is available at <a href="https://github.com/openshift/crankcase">https://github.com/openshift/crankcase</a><br/><br/>
The image contains 5 sets of components:
<ol>
	<li><a href="https://github.com/openshift/crankcase/tree/master/stickshift">Broker</a>: Central service exposing a REST API for consumers and coordinating with the application containers (known as nodes).</li>
	<li><a href="https://github.com/openshift/crankcase/tree/master/gearchanger">Messaging System</a>: A pluggable communication pipeline component for facilitating communication between broker and each node.</li>
	<li><a href="https://github.com/openshift/crankcase/tree/master/swingshift">User Authentication</a>: A pluggable user authentication component with a default MongoDB implementation.</li>
	<li><a href="https://github.com/openshift/crankcase/tree/master/uplift">Domain Name Management</a>:  A pluggable user authentication component that provides DNS management.</li>
	<li><a href="https://github.com/openshift/crankcase/tree/master/cartridges">Cartridges</a>: Management wrappers around software runtimes that will be enabled in both this runtime and the service offering.</li>	
</ol>
</section>

<h1 class="ribbon">Get Started with the OpenShift Origin</h1>
<section id="create_domain_name">
<h3>1. Create a domain name</h3>
<p>
Using your OpenShift Origin login and password, call rhc domain create to create a unique domain name for your applications.<br/>
<pre><b>Note:</b> A login with the username 'admin' and password 'admin' has been created for you.
Additional logins can be created using the ss-create-user command:
    su -c "ss-create-user -u&lt;username&gt; -p&lt;password&gt;"</pre>

</p><pre>$ rhc domain create -n mydomain -l admin
Password: admin
</pre>
<p></p>
<aside>
<p>
The domain names provided above make up part of your app's url.
</p>
</aside>
<aside>
<p>The <code>rhc domain create</code> command will create a configuration file - &lt;your home directory&gt;/.openshift/express.conf - which sets up a default login.</p>
</aside>
</section>
<section class="topic" id="create_application">
<h3>2. Create your first application</h3>
<p>
Now you can create an application.
</p><pre>$ rhc app create -a myapp -t php-5.3
Password: admin</pre>
<p></p>
<p>
This will create a remote git repository for your application, and clone it locally in your current directory.
</p>
<aside>
<p>
OpenShift Origin offers many application stacks. Run <code>rhc app create -h</code> to see all of your options.
</p>
</aside>
<aside>
<p>
Your application's domain name will be &lt;your app name&gt;-&lt;your domain name&gt;.example.com. So, the application created by the example commands would be located at myapp-mydomain.example.com
</p>
</aside>
<aside>
<a href="http://www.youtube.com/watch?v=p83Cx6s_q1U" class="action-more" target="_blank">Creating an application video walkthrough</a>
</aside>
</section>
<section class="topic" id="publish">
<h3>3. Make a change, publish</h3>
<p>
Now that you have created a template application, here's how to update it with your content.
Here's an example for the php framework.
</p>
<pre>$ cd myapp
$ vim php/index.php
(Make a change...  :wq)
$ git commit -a -m "My first change"
$ git push
</pre>
<p>
Use whichever IDE or editor works best for you. Chances are, it'll have git support.
</p>
<p>
Now, check your URL - your change will be live.
</p>
<p><a href="http://www.youtube.com/watch?v=H9rMgKCoW3w" class="action-more" target="_blank">Deploying an application video walkthrough</a></p>
<aside>
<p>
Checkout these great guides for deploying popular frameworks on OpenShift:
</p><ul>
<li><a href="https://www.redhat.com/openshift/blogs/deploying-turbogears2-python-web-framework-using-express">TurboGears2 Python framework</a></li>
<li><a href="https://www.redhat.com/openshift/blogs/deploying-a-pyramid-application-in-a-virtual-python-wsgi-environment-on-red-hat-openshift-expr">Pyramid Python framework</a></li>
<li><a href="https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_Drupal.pdf">Drupal</a></li>
<li><a href="https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_MediaWiki.pdf">MediaWiki</a></li>
</ul>
<p></p>
</aside>
</section>
<section class="topic" id="next_steps">
<h3>4. Next steps</h3>
<p>
Check out the following pages for videos, blogs, and tutorials:
</p><ul>
<li><a href="https://www.redhat.com/openshift/community/videos">Videos</a></li>
<li><a href="http://docs.redhat.com/docs/en-US/OpenShift/2.0/html/User_Guide/index.html">Technical Documentation</a></li>
<li><a href="https://www.redhat.com/openshift/community/forums/">Support Forums</a></li>
</ul>
<p></p>
</section>
<section><a href="https://openshift.redhat.com/app/account/new" class="action-call "><div>Ready to scale in the cloud?</div><div class="highlight">Sign up now</div><div class="highlight-arrow">&gt;</div></a></section>

</div>
</div>
</div>
</div>
</div>
</div>
<footer>
<div id="footer-nav">
<div class="container">
<div class="row">
<div class="span3 link-column">
<header>
<h3>News</h3>
</header>
<ul class="unstyled">
<li><a href="https://www.redhat.com/openshift/forums/news-and-announcements">Announcements</a></li>
<li><a href="https://www.redhat.com/openshift/blogs">Blog</a></li>
<li><a href="http://www.twitter.com/#!/openshift">Twitter</a></li>
</ul>
</div>
<div class="span3 link-column">
<header>
<h3>Community</h3>
</header>
<ul class="unstyled">
<li><a href="https://www.redhat.com/openshift/community/forums/">Forum</a></li>
<li><a href="https://openshift.redhat.com/app/partners">Partner Program</a></li>
<li><a href="http://webchat.freenode.net/?randomnick=1&channels=openshift&uio=d4">IRC Channel</a></li>
<li><a href="mailto:openshift@redhat.com">Feedback</a></li>
</ul>
</div>
<div class="span3 link-column">
<header>
<h3>Legal</h3>
</header>
<ul class="unstyled">
<li><a href="https://openshift.redhat.com/app/legal">Legal</a></li>
<li><a href="https://openshift.redhat.com/app/legal/openshift_privacy">Privacy Policy</a></li>
<li><a href="https://access.redhat.com/security/team/contact/">Security</a></li>
<li><a href="https://openshift.redhat.com/app/legal/opensource_disclaimer">Open Source Disclaimer</a></li>
</ul>
</div>
<div class="span3 link-column">
<header>
<h3>Help</h3>
</header>
<ul class="unstyled">
<li><a href="https://www.redhat.com/openshift/community/faq">FAQ</a></li>
<li><a href="mailto:openshift@redhat.com">Contact</a></li>
</ul>
</div>
</div>
</div>
</div>
<section id="copyright">
<div class="container">
<img alt="Red Hat" src="https://openshift.redhat.com/app/images/redhat.png">
<div class="pull-right">Copyright © 2011 Red Hat, Inc.</div>
</div>
</section>

</footer>
<script src="https://openshift.redhat.com/app/javascripts/jquery.min.js" type="text/javascript"></script>
<script src="https://openshift.redhat.com/app/javascripts/rails.js" type="text/javascript"></script>
<script src="https://openshift.redhat.com/app/javascripts/plugins.js" type="text/javascript"></script>
<script src="https://openshift.redhat.com/app/javascripts/jquery.cookie.js" type="text/javascript"></script>
<script src="https://openshift.redhat.com/app/javascripts/jquery.validate.min.js" type="text/javascript"></script>
<script src="https://openshift.redhat.com/app/javascripts/form.js" type="text/javascript"></script>
<script src="https://openshift.redhat.com/app/javascripts/script.js" type="text/javascript"></script>
</body></html>
EOF
chown apache:apache /var/www/html/getting_started.html
chmod a+r /var/www/html/getting_started.html
/sbin/restorecon /var/www/html/getting_started.html
%end
