#!/bin/bash

source "/etc/openshift/openshift-origin-node.conf"
source "/etc/openshift origin/resource_limits.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

load_resource_limits_conf

application="$1"
uuid="$2"
IP="$3"

APP_HOME="${GEAR_BASE_DIR}/$uuid"
ROCKMONGO_DIR=`echo $APP_HOME/rockmongo-1.1 | tr -s /`

cat <<EOF > "$ROCKMONGO_DIR/conf.d/openshift.conf"
ServerRoot "$ROCKMONGO_DIR"
DocumentRoot "$ROCKMONGO_DIR"
Listen $IP:8080
User $uuid
Group $uuid
ErrorLog "|/usr/sbin/rotatelogs $ROCKMONGO_DIR/logs/error_log$rotatelogs_format $rotatelogs_interval"
CustomLog "|/usr/sbin/rotatelogs $ROCKMONGO_DIR/logs/access_log$rotatelogs_format $rotatelogs_interval" combined

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

cat <<EOF > "$ROCKMONGO_DIR/conf.d/ROCKMONGO.conf"
Alias /rockmongo /$ROCKMONGO_DIR/rockmongo/
EOF
