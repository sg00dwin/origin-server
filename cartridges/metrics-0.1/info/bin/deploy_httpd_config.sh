#!/bin/bash

cartridge_type="metrics-0.1"
source "/etc/stickshift/stickshift-node.conf"
source "/etc/stickshift/resource_limits.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util
CART_INFO_DIR=${CARTRIDGE_BASE_PATH}/embedded/metrics-0.1/info

load_resource_limits_conf

application="$1"
uuid="$2"
IP="$3"

APP_HOME="${GEAR_BASE_DIR}/$uuid"
METRICS_DIR=$(get_cartridge_instance_dir "$cartridge_type")

cat <<EOF > "$METRICS_DIR/conf.d/stickshift.conf"
ServerRoot "$METRICS_DIR"
Listen $IP:8080
User $uuid
Group $uuid
ErrorLog "|/usr/sbin/rotatelogs $METRICS_DIR/logs/error_log$rotatelogs_format $rotatelogs_interval"
CustomLog "|/usr/sbin/rotatelogs $METRICS_DIR/logs/access_log$rotatelogs_format $rotatelogs_interval" combined

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

cat <<EOF > "$METRICS_DIR/conf.d/metrics.conf"
Alias /metrics ${CART_INFO_DIR}/data/metrics/

<Directory /usr/share/metrics/>
   Order Allow,Deny
   Allow from All
</Directory>

EOF
