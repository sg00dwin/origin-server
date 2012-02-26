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

GIT_ROOT=$APP_HOME/git
GIT_DIR=$GIT_ROOT/$application.git
WORKING_DIR=/tmp/${application}_migrate_clone

#TODO add actual standalone.xml migration
#TODO exit on error properly
run_as_user "rm -rf $WORKING_DIR; git clone $GIT_DIR $WORKING_DIR; pushd $WORKING_DIR > /dev/null; echo blah >> blah; git add blah; git commit -m 'blah'; git push; popd > /dev/null; rm -rf $WORKING_DIR" 2>&1 || exit 1
