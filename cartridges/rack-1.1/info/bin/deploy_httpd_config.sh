#!/bin/bash

if [ -f '/etc/libra/node.conf' ]
then
    . /etc/libra/node.conf
elif [ -f 'node.conf' ]
then
    . node.conf
else
    echo "node.conf not found.  Cannot continue" 1>&2
    exit 3
fi

if [ -f '/etc/libra/resource_limits.conf' ]
then
    . /etc/libra/resource_limits.conf
fi

application="$1"
uuid="$2"
IP="$3"

APP_HOME="$libra_dir/$uuid"
APP_DIR=`echo $APP_HOME/$application | tr -s /`

cat <<EOF > "$APP_DIR/conf.d/libra.conf"
ServerRoot "$APP_DIR"
DocumentRoot "$APP_DIR/deploy/public"
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

PassengerUser $uuid
PassengerPreStart http://$IP:8080/
PassengerUseGlobalQueue off
<Directory $APP_DIR/deploy/public>
  AllowOverride all
  Options -MultiViews
</Directory>

EOF