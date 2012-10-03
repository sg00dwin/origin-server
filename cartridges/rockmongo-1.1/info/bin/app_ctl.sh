#!/bin/bash -e

source "/etc/stickshift/stickshift-node.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/apache

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

cartridge_type="rockmongo-1.1"
cartridge_dir=$OPENSHIFT_HOMEDIR/$cartridge_type

validate_run_as_user

export PHPRC="${OPENSHIFT_HOMEDIR}/${cartridge_type}/conf/php.ini"

CART_CONF_DIR=${CARTRIDGE_BASE_PATH}/embedded/rockmongo-1.1/info/configuration/etc/conf
HTTPD_CFG_FILE=$CART_CONF_DIR/httpd_nolog.conf
HTTPD_PID_FILE=${OPENSHIFT_HOMEDIR}/${cartridge_type}/run/httpd.pid

case "$1" in
    start)
        if [ -f ${cartridge_dir}/run/stop_lock ]
        then
            echo "Application is explicitly stopped!  Use 'rhc app cartridge start -a ${cartridge_type} -c rockmongo-1.1' to start back up." 1>&2
            exit 0
        else
            ensure_valid_httpd_process "$HTTPD_PID_FILE" "$HTTPD_CFG_FILE"
            src_user_hook pre_start_rockmongo-1.1
            /usr/sbin/httpd -C "Include ${cartridge_dir}/conf.d/*.conf" -f $HTTPD_CFG_FILE -k $1
            run_user_hook post_start_rockmongo-1.1
        fi
    ;;

    graceful-stop|stop)
        # Don't exit on errors on stop.
        set +e
        src_user_hook pre_stop_rockmongo-1.1
        httpd_pid=`cat "$HTTPD_PID_FILE" 2> /dev/null`
        ensure_valid_httpd_process "$HTTPD_PID_FILE" "$HTTPD_CFG_FILE"
        /usr/sbin/httpd -C "Include ${cartridge_dir}/conf.d/*.conf" -f $HTTPD_CFG_FILE -k $1
        wait_for_stop $httpd_pid
        run_user_hook post_stop_rockmongo-1.1
    ;;

    restart|graceful)
        ensure_valid_httpd_process "$HTTPD_PID_FILE" "$HTTPD_CFG_FILE"
        src_user_hook pre_start_rockmongo-1.1
        /usr/sbin/httpd -C "Include ${cartridge_dir}/conf.d/*.conf" -f $HTTPD_CFG_FILE -k $1
        run_user_hook post_start_rockmongo-1.1
    ;;
esac
