#!/bin/bash -e

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/li-controller/info/lib/util

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if ! [ $# -eq 1 ]
then
    echo "Usage: \$0 [start|restart|graceful|graceful-stop|stop]"
    exit 1
fi
validate_user_context.sh

. app_ctl_pre.sh

case "$1" in
    start)
    ;;
    graceful-stop|stop)
    ;;
    restart|graceful)
    ;;
    reload)
    ;;
    status)
        print_running_processes
    ;;
esac
