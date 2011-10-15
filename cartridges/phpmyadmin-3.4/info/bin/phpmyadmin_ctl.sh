#!/bin/bash -e

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

function wait_for_pid()
{
    pid=$1
    for i in {1..60}
    do
        if `ps --pid $pid > /dev/null 2>&1`
        then
            echo "Waiting for stop to finish"
            sleep .5
        else
            break
        fi
    done
}

if ! [ $# -eq 1 ]
then
    echo "Usage: $0 [start|restart|graceful|graceful-stop|stop]"
    exit 1
fi


validate_user_context.sh

export PHPRC="${OPENSHIFT_PHPMYADMIN_APP_DIR}conf/php.ini"

CART_CONF_DIR=/usr/libexec/li/cartridges/embedded/phpmyadmin-3.4/info/configuration/etc/conf

case "$1" in
    start)
        if [ -f ${OPENSHIFT_PHPMYADMIN_APP_DIR}run/stop_lock ]
        then
            echo "Application is explicitly stopped!  Use 'rhc-ctl-app -a ${OPENSHIFT_APP_NAME} -e start-phpmyadmin-3.4' to start back up." 1>&2
            exit 0
        else
            /usr/sbin/httpd -C 'Include ${OPENSHIFT_PHPMYADMIN_APP_DIR}conf.d/*.conf' -f $CART_CONF_DIR/httpd_nolog.conf -k $1
        fi
    ;;

    graceful-stop|stop)
        httpd_pid=`cat ${OPENSHIFT_PHPMYADMIN_APP_DIR}run/httpd.pid 2> /dev/null`
        /usr/sbin/httpd -C 'Include ${OPENSHIFT_PHPMYADMIN_APP_DIR}conf.d/*.conf' -f $CART_CONF_DIR/httpd_nolog.conf -k $1
        wait_for_pid $httpd_pid
    ;;

    restart|graceful)
        /usr/sbin/httpd -C 'Include ${OPENSHIFT_PHPMYADMIN_APP_DIR}conf.d/*.conf' -f $CART_CONF_DIR/httpd_nolog.conf -k $1
    ;;
esac
