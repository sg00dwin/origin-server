#!/bin/bash -e

source /etc/stickshift/stickshift-node.conf
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

export STOPTIMEOUT=10

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

translate_env_vars

export HAPROXY_PID="${OPENSHIFT_RUN_DIR}/haproxy.pid"

if ! [ $# -eq 1 ]
then
    echo "Usage: \$0 [start|restart|graceful|graceful-stop|stop]"
    exit 1
fi

validate_run_as_user

. app_ctl_pre.sh

isrunning() {
    if [ -f "${HAPROXY_PID}" ]; then
        haproxy_pid=`$HAPROXY_PID 2> /dev/null`
        if `ps --pid $haproxy_pid > /dev/null 2>&1` || `pgrep -x haproxy > /dev/null 2>&1`
        then
            return 0
        fi
    fi
    return 1
}

start() {
    set_app_state started
    if ! isrunning
    then
        /usr/sbin/haproxy -f $OPENSHIFT_GEAR_DIR/conf/haproxy.cfg > /dev/null 2>&1
        #haproxy_ctld_daemon start > /dev/null 2>&1
    else
        echo "Haproxy already running" 1>&2
    fi
}


stop() {
    set_app_state stopped
    #haproxy_ctld_daemon stop > /dev/null 2>&1
    if [ -f $HAPROXY_PID ]; then
        pid=$( /bin/cat "${HAPROXY_PID}" )
        /bin/kill $pid
        ret=$?
        if [ $ret -eq 0 ]; then
            TIMEOUT="$STOPTIMEOUT"
            while [ $TIMEOUT -gt 0 ] && [ -f "$HAPROXY_PID" ]; do
                /bin/kill -0 "$pid" >/dev/null 2>&1 || break
                sleep 1
                let TIMEOUT=${TIMEOUT}-1
            done
        fi
    else
        if `pgrep -x haproxy > /dev/null 2>&1`
        then
            echo "Warning: Haproxy process exists without a pid file.  Use force-stop to kill." 1>&2
        else
            echo "Haproxy already stopped" 1>&2
        fi
    fi
}


reload() {
    if ! isrunning; then
       start
    else
        [ -f $HAPROXY_PID ]  &&  zpid=$( /bin/cat "${HAPROXY_PID}" )
        [ -n "$zpid" ]       &&  zopts="-sf $zpid"
        echo "Reloading haproxy gracefully without service interruption" 1>&2
        /usr/sbin/haproxy -f $OPENSHIFT_GEAR_DIR/conf/haproxy.cfg ${zopts} > /dev/null 2>&1
    fi
    #haproxy_ctld_daemon restart > /dev/null 2>&1
}


case "$1" in
    start)
        #/usr/sbin/haproxy -f $OPENSHIFT_GEAR_DIR/conf/haproxy.cfg
        start
    ;;
    graceful-stop|stop)
        stop
    ;;
    graceful)
        /bin/kill -HUP `cat $OPENSHIFT_RUN_DIR/haproxy.pid`
    ;;
    restart)
    ;;
    reload)
        reload;
    ;;
    status)
        print_running_processes
    ;;
esac
