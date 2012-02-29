#!/bin/bash

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

set_app_state building
if [ -x ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/build ]
then
    echo "Running .openshift/action_hooks/build"
    ${OPENSHIFT_REPO_DIR}.openshift/action_hooks/build
fi
