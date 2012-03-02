#!/bin/bash

CART_DIR=$(dirname $(dirname $(dirname $0)))
source ${CART_DIR}/info/bin/load_config.sh
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

CART_CONF_DIR=${CARTRIDGE_BASE_PATH}/${OPENSHIFT_APP_TYPE}/info/configuration/etc/conf

# Stop the app
set_app_state stopped
httpd_pid=`cat ${OPENSHIFT_RUN_DIR}httpd.pid 2> /dev/null`
/usr/sbin/httpd -C "Include ${OPENSHIFT_APP_DIR}conf.d/*.conf" -f $CART_CONF_DIR/httpd_nolog.conf -k $1
wait_for_stop $httpd_pid
