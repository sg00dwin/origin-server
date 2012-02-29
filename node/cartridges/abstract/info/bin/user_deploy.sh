#!/bin/bash

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

set_app_state deploying

if [ -x ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/deploy ]
then
    echo "Running .openshift/action_hooks/deploy"
    ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/deploy
fi
