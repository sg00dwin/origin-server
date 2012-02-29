#!/bin/bash

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util

set_app_state deploying

start_dbs

user_deploy.sh
