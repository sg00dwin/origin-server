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
    echo "runuser --shell /bin/sh $OPENSHIFT_APP_UUID $PSQL_DIR/${OPENSHIFT_APP_NAME}_postgresql_ctl.sh" 1>&2
    echo 2>&1
    exit 15
fi

PSQL_DIR="$OPENSHIFT_HOMEDIR/postgresql-8.4/"
PSQL_DATADIR="$PSQL_DIR/data"
PSQL_LOGFILE="$PSQL_DIR/logs/postgres.log"
CART_DIR=${CART_DIR:=/usr/libexec/li/cartridges}
CART_INFO_DIR=$CART_DIR/embedded/postgresql-8.4/info
source ${CART_INFO_DIR}/lib/util

isrunning() {
    if [ -f $PSQL_DIR/pid/postgres.pid ]; then
        postgres_pid=`$PSQL_DIR/pid/postgres.pid 2> /dev/null`
        myid=`id -u`
        if `ps --pid $postgres_pid 2>&1 | grep postgres > /dev/null 2>&1` || `pgrep -x postgres -u $myid > /dev/null 2>&1`
        then
            return 0
        fi
    fi
    return 1
}

start() {
	if ! isrunning
    then
        /usr/bin/postgres -D $PSQL_DATADIR -h $OPENSHIFT_INTERNAL_IP -N 5 > $PSQL_LOGFILE 2>&1 &
        wait_to_start_as_user
    else
        echo "PostgreSQL server already running" 1>&2
    fi
}

stop() {
    if [ -f $PSQL_DIR/pid/postgres.pid ]; then
    	pid=$( /bin/cat $PSQL_DIR/pid/postgres.pid )
    fi

    if [ -n "$pid" ]; then
        /bin/kill $pid
        ret=$?
        if [ $ret -eq 0 ]; then
            TIMEOUT="$STOPTIMEOUT"
            while [ $TIMEOUT -gt 0 ] && [ -f "$PSQL_DIR/pid/postgres.pid" ]; do
                /bin/kill -0 "$pid" >/dev/null 2>&1 || break
                sleep 1
                let TIMEOUT=${TIMEOUT}-1
            done
        fi
    else
        myid=`id -u`
        if `pgrep -x postgres -u $myid  > /dev/null 2>&1`
        then
        	echo "Warning: PostgreSQL server process exists without a pid file.  Use force-stop to kill." 1>&2
        else
            echo "PostgreSQL server already stopped" 1>&2
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
            echo "PostgreSQL server is running" 1>&2
        else
            echo "PostgreSQL server is stopped" 1>&2
        fi
        exit 0
    ;;
esac
