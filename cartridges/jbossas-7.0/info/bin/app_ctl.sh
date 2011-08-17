#!/bin/bash -e

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

APP_JBOSS="$OPENSHIFT_APP_DIR"/${OPENSHIFT_APP_TYPE}
APP_JBOSS_TMP_DIR="$APP_JBOSS"/standalone/tmp
APP_JBOSS_BIN_DIR="$APP_JBOSS"/bin

# For debugging, capture script output into app tmp dir
#pid=$$
exec 4>&1 > /dev/null 2>&1  # Link file descriptor 4 with stdout, saves stdout.
exec > "$APP_JBOSS_TMP_DIR/jbossas7-${OPENSHIFT_APP_NAME}_ctl-$1.${pid}.log" 2>&1

# Kill the process given by $1 and its children
killtree() {
    local _pid=$1
    for _child in $(ps -o pid --no-headers --ppid ${_pid}); do
        killtree ${_child}
    done
    echo kill -TERM ${_pid}
    kill -TERM ${_pid}
}
# Check if the jbossas process is running
isrunning() {
    # Check for running app
    if [ -f "$JBOSS_PID_FILE" ]; then
      jbpid=$(cat $JBOSS_PID_FILE);
      if /bin/ps --pid $jbpid 1>&2 >/dev/null;
      then
        return 0
      fi
    fi
    # not running
    return 1
}
# Check if the server http port is up
function ishttpup() {
    let count=0
    while [ ${count} -lt 10 ]
    do
        if /usr/sbin/lsof -P -n -i "@${OPENSHIFT_INTERNAL_IP}:8080" | grep "(LISTEN)" > /dev/null; then
            echo "Found ${OPENSHIFT_INTERNAL_IP}:8080 listening port"
            return 0
        fi
        let count=${count}+1
        sleep 2
    done
    return 1
}


JBOSS_PID_FILE="$OPENSHIFT_APP_DIR/run/jboss.pid"

case "$1" in
    start)
        if [ -f $OPENSHIFT_APP_DIR/run/stop_lock ]
        then
            echo " - Application is disabled" 1>&2
            exit 0
        else
            # Check for running app
            if isrunning; then
                jbpid=$(cat $JBOSS_PID_FILE);
                echo " - Application($jbpid) is already running" 1>&2
                exit 0
            fi
            # Start
            $APP_JBOSS_BIN_DIR/standalone.sh 1>&2 >${APP_JBOSS_TMP_DIR}/${OPENSHIFT_APP_NAME}.log &
            PROCESS_ID=$!
            echo $PROCESS_ID > $JBOSS_PID_FILE
            if ! ishttpup; then
                echo "Timed out waiting for http listening port"
                exit 1
            fi
        fi
    ;;
    graceful-stop|stop)
        echo "JBOSS PID FILE:" $JBOSS_PID_FILE
        if ! isrunning; then
            jbpid=$(cat $JBOSS_PID_FILE);
            echo " - Application($jbpid) is already running" 1>&2
            exit 0
        fi
        # kill the process tree
        if [ -f "$JBOSS_PID_FILE" ]; then
          pid=$(cat $JBOSS_PID_FILE);
          echo "Sending SIGTERM to jboss:$pid ...";
          killtree $pid
        else
          echo "Failed to locate JBOSS PID File"
        fi
        exit 0
    ;;
    restart|graceful)
        $OPENSHIFT_APP_DIR/${OPENSHIFT_APP_NAME}_ctl.sh stop
        $OPENSHIFT_APP_DIR/${OPENSHIFT_APP_NAME}_ctl.sh start
    ;;
    status)
        # Restore stdout and close file descriptor #4
        exec 1>&4 4>&-
        if ! isrunning; then
            echo " - Application is NOT running"
            exit 0
        fi

        echo tailing "$APP_JBOSS/standalone/log/server.log"
        echo "------ Tail of ${OPENSHIFT_APP_NAME} application server.log ------"
        tail "$APP_JBOSS/standalone/log/server.log"
        exit 0
    ;;
esac