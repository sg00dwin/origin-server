#!/bin/bash

source "/etc/stickshift/stickshift-node.conf"
source "/etc/stickshift/resource_limits.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

cartridge_dir="$1"
IP="$2"

cat <<EOF > "$cartridge_dir/conf.d/zendserver_gui.conf"
# Warning: Modifying this file will break the Zend Server Administration Interface
Listen $IP:16083
NameVirtualHost $IP:16083
# do not allow override of this value for the UI's Vhost as it should always be off when generating non-html content such as dynamic images
<VirtualHost *:16083>
  php_admin_flag tidy.clean_output off
  php_admin_flag session.auto_start off
  Alias /ZendServer "/usr/local/zend/gui/UserServer"
  DocumentRoot /usr/local/zend/gui/UserServer
  ErrorLog "|/usr/sbin/rotatelogs $cartridge_dir/logs/gui_vhost_error_log$rotatelogs_format $rotatelogs_interval"
  CustomLog "|/usr/sbin/rotatelogs $cartridge_dir/logs/gui_vhost_access_log$rotatelogs_format $rotatelogs_interval" combined
  <Directory /usr/local/zend/gui/UserServer>
	Options Indexes FollowSymLinks MultiViews
	AllowOverride None
	Order deny,allow
	deny from all
    allow from 127.0.0.1/8
  </Directory>
  
  ServerSignature On

</VirtualHost>
EOF
