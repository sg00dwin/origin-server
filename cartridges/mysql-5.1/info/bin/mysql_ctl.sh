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

STOPTIMEOUT=5

if whoami | grep -q root
then
    echo 1>&2
    echo "Please don't run script as root, try:" 1>&2
    echo "runuser --shell /bin/sh $OPENSHIFT_APP_UUID $MYSQL_DIR/${OPENSHIFT_APP_NAME}_mysql_ctl.sh" 1>&2
    echo 2>&1
    exit 15
fi

MYSQL_DIR="$OPENSHIFT_HOMEDIR/mysql-5.1/"

start(){

        /usr/bin/mysqld_safe --defaults-file=$MYSQL_DIR/etc/my.cnf >/dev/null 2>&1 &
}

stop(){
    if [ -f $MYSQL_DIR/pid/mysql.pid ]; then
        /bin/kill $( /bin/cat $MYSQL_DIR/pid/mysql.pid )
        ret=$?
        if [ $ret -eq 0 ]; then
            TIMEOUT="$STOPTIMEOUT"
            while [ $TIMEOUT -gt 0 ] && [ ! -f $MYSQL_DIR/pid/mysql.pid ]; do
                /bin/kill -0 "$( /bin/cat $MYSQL_DIR/pid/mysql.pid )" >/dev/null 2>&1 || break
                sleep 1
                let TIMEOUT=${TIMEOUT}-1
            done
        fi
    else
        echo "Mysql already stopped"
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
        echo " Coming soon"
        exit 0
    ;;
esac