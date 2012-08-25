#!/bin/bash -e

source "/etc/stickshift/stickshift-node.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if ! [ $# -eq 1 ]
then
    echo "Usage: $0 [start|restart|graceful|graceful-stop|stop]"
    exit 1
fi

validate_run_as_user

export PHPRC="${OPENSHIFT_PHPMOADMIN_GEAR_DIR}conf/php.ini"

CART_CONF_DIR=${CARTRIDGE_BASE_PATH}/embedded/phpmoadmin-1.0/info/configuration/etc/conf

case "$1" in
    start)
        if [ -f ${OPENSHIFT_PHPMOADMIN_GEAR_DIR}run/stop_lock ]
        then
            echo "Application is explicitly stopped!  Use 'rhc app cartridge start -a ${OPENSHIFT_GEAR_NAME} -c phpmoadmin-1.0' to start back up." 1>&2
            exit 0
        else
            src_user_hook pre_start_phpmoadmin-1.0
            /usr/sbin/httpd -C "Include ${OPENSHIFT_PHPMOADMIN_GEAR_DIR}/conf.d/*.conf" -f $CART_CONF_DIR/httpd_nolog.conf -k $1
            run_user_hook post_start_phpmoadmin-1.0
        fi
    ;;

    graceful-stop|stop)
        if [ -f ${OPENSHIFT_PHPMOADMIN_GEAR_DIR}run/httpd.pid ]
        then
            src_user_hook pre_stop_phpmoadmin-1.0
            httpd_pid=`cat ${OPENSHIFT_PHPMOADMIN_GEAR_DIR}run/httpd.pid 2> /dev/null`
            /usr/sbin/httpd -C "Include ${OPENSHIFT_PHPMOADMIN_GEAR_DIR}/conf.d/*.conf" -f $CART_CONF_DIR/httpd_nolog.conf -k $1
            wait_for_stop $httpd_pid
            run_user_hook post_stop_phpmoadmin-1.0
        fi
    ;;

    restart|graceful)
        src_user_hook pre_start_phpmoadmin-1.0
        /usr/sbin/httpd -C "Include ${OPENSHIFT_PHPMOADMIN_GEAR_DIR}/conf.d/*.conf" -f $CART_CONF_DIR/httpd_nolog.conf -k $1
        run_user_hook post_start_phpmoadmin-1.0
    ;;
esac
