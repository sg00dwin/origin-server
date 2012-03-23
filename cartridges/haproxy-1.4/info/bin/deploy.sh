#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

source /etc/stickshift/stickshift-node.conf
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

export GIT_SSH="${CARTRIDGE_BASE_PATH}/haproxy-1.4/info/bin/ssh"

user_deploy.sh
