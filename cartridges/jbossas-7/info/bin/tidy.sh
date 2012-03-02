#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

CART_DIR=$(dirname $(dirname $(dirname $0)))
source ${CART_DIR}/info/bin/load_config.sh
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

standalone_tmp=${OPENSHIFT_APP_DIR}${OPENSHIFT_APP_TYPE}/standalone/tmp/
if [ -d $standalone_tmp ]
then
    client_message "Emptying tmp dir: $standalone_tmp"
    rm -rf $standalone_tmp/* $standalone_tmp/.[^.]*
fi