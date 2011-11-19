#!/bin/bash

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/li-controller/info/lib/util

load_node_conf

load_resource_limits_conf

application="$1"
uuid="$2"
IP="$3"

APP_HOME="$libra_dir/$uuid"
PHPMOADMIN_DIR=`echo $APP_HOME/phpmoadmin-1.0 | tr -s /`

cat <<EOF > "$PHPMOADMIN_DIR/conf.d/libra.conf"
ServerRoot "$PHPMOADMIN_DIR/html"
Listen $IP:8080
User $uuid
Group $uuid
ErrorLog "|/usr/sbin/rotatelogs $PHPMOADMIN_DIR/logs/error_log$rotatelogs_format $rotatelogs_interval"
CustomLog "|/usr/sbin/rotatelogs $PHPMOADMIN_DIR/logs/access_log$rotatelogs_format $rotatelogs_interval" combined

php_value include_path "."

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

cat <<EOF > "$PHPMOADMIN_DIR/conf.d/phpMoAdmin.conf"
Alias /phpmoadmin /moadmin.php
EOF
