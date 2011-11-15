#!/bin/bash
if ! [ $# -eq 1 ]
then
    echo "Usage: $0 [start|restart|stop]"
    exit 1
fi

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

export STOPTIMEOUT=10

if whoami | grep -q root
then
    echo 1>&2
    echo "Please don't run script as root, try:" 1>&2
    echo "runuser --shell /bin/sh $OPENSHIFT_APP_UUID $MONGODB_DIR/${OPENSHIFT_APP_NAME}_mongodb_ctl.sh" 1>&2
    echo 2>&1
    exit 15
fi

MONGODB_DIR="$OPENSHIFT_HOMEDIR/mongodb-2.0/"

isrunning() {
    if [ -f $MONGODB_DIR/pid/mongodb.pid ]; then
        mongodb_pid=`$MONGODB_DIR/pid/mongodb.pid 2> /dev/null`
        if `ps --pid $mongodb_pid > /dev/null 2>&1` || `pgrep mongod > /dev/null 2>&1`
        then
            return 0
        fi
    fi
    return 1
}

start() {
	if ! isrunning
    then
        /usr/bin/mongod --nojournal --smallfiles --quiet -f $MONGODB_DIR/etc/mongodb.conf run >/dev/null 2>&1 &
    else
        echo "Mongodb already running" 1>&2
    fi
}

stop() {
    if [ -f $MONGODB_DIR/pid/mongodb.pid ]; then
    	pid=$( /bin/cat $MONGODB_DIR/pid/mongodb.pid )
        /bin/kill $pid
        ret=$?
        if [ $ret -eq 0 ]; then
            TIMEOUT="$STOPTIMEOUT"
            while [ $TIMEOUT -gt 0 ] && [ -f "$MONGODB_DIR/pid/mongodb.pid" ]; do
                /bin/kill -0 "$pid" >/dev/null 2>&1 || break
                sleep 1
                let TIMEOUT=${TIMEOUT}-1
            done
        fi
    else
        if `pgrep mongod > /dev/null 2>&1`
        then
        	echo "Warning: Mongodb process exists without a pid file.  Use force-stop to kill." 1>&2
        else
            echo "Mongodb already stopped" 1>&2
        fi
    fi
}

case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart)
        stop
        start
    ;;
    status)
        if isrunning
        then
            echo "Mongodb is running" 1>&2
        else
            echo "Mongodb is stopped" 1>&2
        fi
        exit 0
    ;;
esac
