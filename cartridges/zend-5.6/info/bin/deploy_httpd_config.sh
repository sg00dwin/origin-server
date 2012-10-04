#!/bin/bash

source "/etc/stickshift/stickshift-node.conf"
source "/etc/stickshift/resource_limits.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

cartridge_dir="$1"
application="$2"
uuid="$3"
IP="$4"

APP_HOME="$GEAR_BASE_DIR/$uuid"
source "$APP_HOME/.env/OPENSHIFT_REPO_DIR"

cat <<EOF > "$cartridge_dir/conf.d/stickshift.conf"
ServerRoot "$cartridge_dir"
DocumentRoot "$OPENSHIFT_REPO_DIR/php"
Listen $IP:8080
User $uuid
Group $uuid
ErrorLog "|/usr/sbin/rotatelogs $cartridge_dir/logs/error_log$rotatelogs_format $rotatelogs_interval"
CustomLog "|/usr/sbin/rotatelogs $cartridge_dir/logs/access_log$rotatelogs_format $rotatelogs_interval" combined
#php_value include_path ".:$OPENSHIFT_REPO_DIR/libs/:$cartridge_dir/phplib/pear/pear/php/:/usr/share/pear/:$OPENSHIFT_HOMEDIR/zend-5.6/share/ZendFramework/library:$OPENSHIFT_HOMEDIR/zend-5.6/share/pear"
# TODO: Adjust from ALL to more conservative values
<Directory "$OPENSHIFT_REPO_DIR/php">
  AllowOverride All
</Directory>
Include "${cartridge_dir}/etc/sites.d/zend-default-vhost-80.conf"
# TODO: Adjust from ALL to more conservative values
<IfModule !mod_bw.c>
    LoadModule bw_module    modules/mod_bw.so
</IfModule>

<ifModule mod_bw.c>
  BandWidthModule On
  ForceBandWidthModule On
  BandWidth $apache_bandwidth
  MaxConnection $apache_maxconnection
  BandWidthError $apache_bandwidtherror
</IfModule>

EOF
