#!/bin/bash

source "/etc/stickshift/stickshift-node.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

application="$1"
uuid="$2"
IP="$3"

APP_HOME="$GEAR_BASE_DIR/$uuid"
APP_DIR=`echo $APP_HOME/$application | tr -s /`

cat <<EOF > "$APP_DIR/conf.d/stickshift.conf"
ServerRoot "$APP_DIR"
DocumentRoot "$APP_DIR/repo/wsgi"
Listen $IP:8080
User $uuid
Group $uuid

ErrorLog "|/usr/sbin/rotatelogs $APP_DIR/logs/error_log$rotatelogs_format $rotatelogs_interval"
CustomLog "|/usr/sbin/rotatelogs $APP_DIR/logs/access_log$rotatelogs_format $rotatelogs_interval" combined
 
<Directory $APP_DIR/repo/wsgi>
  AllowOverride all
  Options -MultiViews
</Directory>

WSGIScriptAlias / "$APP_DIR/repo/wsgi/application"
Alias /static "$APP_DIR/repo/wsgi/static/"
WSGIPythonPath "$APP_DIR/repo/libs:$APP_DIR/repo/wsgi:$APP_DIR/virtenv/lib/python2.6/"
WSGIPassAuthorization On

EOF