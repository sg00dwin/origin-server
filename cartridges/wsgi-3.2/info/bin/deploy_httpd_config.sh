#!/bin/bash

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util

load_node_conf

load_resource_limits_conf

application="$1"
uuid="$2"
IP="$3"

APP_HOME="$libra_dir/$uuid"
APP_DIR=`echo $APP_HOME/$application | tr -s /`

cat <<EOF > "$APP_DIR/conf.d/libra.conf"
ServerRoot "$APP_DIR"
DocumentRoot "$APP_DIR/repo/wsgi"
Listen $IP:8080
User $uuid
Group $uuid

ErrorLog "|/usr/sbin/rotatelogs $APP_DIR/logs/error_log$rotatelogs_format $rotatelogs_interval"
CustomLog "|/usr/sbin/rotatelogs $APP_DIR/logs/access_log$rotatelogs_format $rotatelogs_interval" combined
 
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

<Directory $APP_DIR/repo/wsgi>
  AllowOverride all
  Options -MultiViews
</Directory>

WSGIScriptAlias / "$APP_DIR/repo/wsgi/application"
Alias /static "$APP_DIR/repo/wsgi/static/"
WSGIPythonPath "$APP_DIR/repo/libs:$APP_DIR/repo/wsgi:$APP_DIR/virtenv/lib/python2.6/"
WSGIPassAuthorization On

EOF