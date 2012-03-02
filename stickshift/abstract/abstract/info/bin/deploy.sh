#!/bin/bash

CART_DIR=$(dirname $(dirname $(dirname $0)))
source ${CART_DIR}/info/bin/load_config.sh
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

start_dbs

user_deploy.sh
