#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

CART_DIR=$(dirname $(dirname $(dirname $0)))
source ${CART_DIR}/info/bin/load_config.sh
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

start_dbs

# Run build
#virtualenv --relocatable ${OPENSHIFT_APP_DIR}virtenv
#. ./bin/activate

if [ -d ${OPENSHIFT_APP_DIR}virtenv ]
then 
    pushd ${OPENSHIFT_APP_DIR}virtenv > /dev/null
    . ./bin/activate
    popd > /dev/null
fi

user_deploy.sh