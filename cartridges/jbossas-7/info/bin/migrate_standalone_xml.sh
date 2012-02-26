#!/bin/bash

# Exit on any errors
set -e

function print_help {
    echo "Usage: $0 app-name uuid"

    echo "$0 $@" | logger -p local0.notice -t libra_jboss_migrate_standalone_xml
    exit 1
}

while getopts 'd' OPTION
do
    case $OPTION in
        d) set -x
        ;;
        ?) print_help
        ;;
    esac
done

[ $# -eq 2 ] || print_help

CART_DIR=${CART_DIR:=/usr/libexec/li/cartridges}

source ${CART_DIR}/abstract/info/lib/util

load_node_conf

application="$1"
uuid=$2

setup_basic_vars

GIT_DIR=$APP_HOME/git/$application.git
WORKING_DIR=/tmp/${application}_migrate_clone

run_as_user "$CART_DIR/jbossas-7/info/bin/migrate_standalone_xml_as_user.sh $WORKING_DIR $GIT_DIR 2>&1" || exit 1
