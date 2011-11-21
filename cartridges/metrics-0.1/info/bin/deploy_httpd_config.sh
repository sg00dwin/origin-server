#!/bin/bash

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util
CART_INFO_DIR=$CART_DIR/embedded/metrics-0.1/info

load_node_conf

load_resource_limits_conf

application="$1"
uuid="$2"
IP="$3"

APP_HOME="$libra_dir/$uuid"
METRICS_DIR=`echo $APP_HOME/metrics-0.1 | tr -s /`

cat <<EOF > "$METRICS_DIR/conf.d/libra.conf"
ServerRoot "$METRICS_DIR"
Listen $IP:8080
User $uuid
Group $uuid
ErrorLog "|/usr/sbin/rotatelogs $METRICS_DIR/logs/error_log$rotatelogs_format $rotatelogs_interval"
CustomLog "|/usr/sbin/rotatelogs $METRICS_DIR/logs/access_log$rotatelogs_format $rotatelogs_interval" combined

php_value include_path "."
EOF

cat <<EOF > "$METRICS_DIR/conf.d/metrics.conf"
Alias /metrics ${CART_INFO_DIR}/data/metrics/

<Directory /usr/share/metrics/>
   Order Allow,Deny
   Allow from All
</Directory>

EOF