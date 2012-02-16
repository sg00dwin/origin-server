#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util

export GIT_SSH="/usr/libexec/li/cartridges/haproxy-1.4/info/bin/ssh"
GIT_DIR=~"/git/${OPENSHIFT_APP_NAME}.git/" git push

user_deploy.sh
