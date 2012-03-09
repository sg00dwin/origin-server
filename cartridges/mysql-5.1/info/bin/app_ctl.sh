#!/bin/bash -e

CART_DIR=/usr/libexec/li/cartridges
CART_NAME="mysql"
CART_VERSION="5.1"
source ${CART_DIR}/abstract/info/lib/util

# Import Environment Variables
for f in ~/.env/*; do
    . $f
done

if ! [ $# -eq 1 ]; then
    echo "Usage: \$0 [start|restart|reload|graceful|graceful-stop|stop|status]"
    exit 1
fi

validate_run_as_user

. app_ctl_pre.sh

mysql_ctl="$OPENSHIFT_HOMEDIR/$CART_NAME-$CART_VERSION/${OPENSHIFT_APP_NAME}_mysql_ctl.sh"

case "$1" in
    start)                    "$mysql_ctl" start    ;;
    restart|reload|graceful)  "$mysql_ctl" restart  ;;
    stop|graceful-stop)       "$mysql_ctl" stop     ;;
    status)                   "$mysql_ctl" status   ;;
esac
