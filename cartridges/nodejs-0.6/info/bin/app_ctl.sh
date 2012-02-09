#!/bin/bash

CART_DIR=/usr/libexec/li/cartridges
STOPTIMEOUT=10

function _is_node_service_running() {
    if [ -f $OPENSHIFT_APP_DIR/run/node.pid ]; then
        node_pid=$( cat $OPENSHIFT_APP_DIR/run/node.pid 2> /dev/null )
        myid=$( id -u )
        if `ps --pid $node_pid 2>&1 | grep node > /dev/null 2>&1`  ||  \
           `pgrep -x node -u $myid > /dev/null 2>&1`; then
            return 0
        fi
    fi

    return 1

}  #  End of function  _is_node_running.


function _status_node_service() {
    if _is_node_service_running; then
        app_state="running"
    else
        app_state="either stopped or inaccessible"
    fi

    echo "Application '$OPENSHIFT_APP_NAME' is $app_state" 1>&2

}  #  End of function  _status_node_service.


function _start_node_service() {
    if [ -f $OPENSHIFT_APP_DIR/run/stop_lock ]; then
        echo "Application is explicitly stopped!  Use 'rhc-ctl-app -a ${OPENSHIFT_APP_NAME} -c start' to start back up." 1>&2
        return 0
    else
        # Check if service is running.
        if _is_node_service_running; then
            echo "Application '$OPENSHIFT_APP_NAME' is already running" 1>&2
            return 0
        fi
    fi

    #  Got here - it means that we need to start up Node.

    envf="$OPENSHIFT_APP_DIR/conf/node.env"
    logf="$OPENSHIFT_APP_DIR/logs/node.log"

    #  Source environment if it exists.
    [ -f "$envf" ]  &&  source "$envf"

    #  Ensure we have script file.
    node_app=${node_app:-"server.js"}

    pushd "$OPENSHIFT_REPO_DIR" > /dev/null
    node $node_opts $node_app $node_app_args > $logf 2>&1 &
    ret=$?
    npid=$!
    popd > /dev/null
    if [ $ret -eq 0 ]; then
        echo "$npid" > "$OPENSHIFT_APP_DIR/run/node.pid"
    else
        echo "Application '$OPENSHIFT_APP_NAME' failed to start - $ret" 1>&2
    fi

}  #  End of function  _start_node_service.


function _stop_node_service() {
    if [ -f $OPENSHIFT_APP_DIR/run/node.pid ]; then
        node_pid=$( cat $OPENSHIFT_APP_DIR/run/node.pid 2> /dev/null )
    fi

    if [ -n "$node_pid" ]; then
        # FIXME: kill -TERM doesn't seem to be sent to the process.
        # /bin/kill $node_pid
        /bin/kill -9 $node_pid
        ret=$?
        if [ $ret -eq 0 ]; then
            TIMEOUT="$STOPTIMEOUT"
            while [ $TIMEOUT -gt 0 ]  &&  _is_node_service_running ; do
                /bin/kill -0 "$node_pid" >/dev/null 2>&1 || break
                sleep 1
                let TIMEOUT=${TIMEOUT}-1
            done
        fi
        rm -f $OPENSHIFT_APP_DIR/run/node.pid
    else
        if `pgrep -x node -u $(id -u)  > /dev/null 2>&1`; then
            echo "Warning: Application '$OPENSHIFT_APP_NAME' Node server exists without a pid file.  Use force-stop to kill." 1>&2
        fi
    fi

}  #  End of function  _stop_node_service.


function _restart_node_service() {
    _stop_node_service
    _start_node_service

}  #  End of function  _restart_node_service.



#
#  main():
#

# Ensure arguments.
if ! [ $# -eq 1 ]; then
    echo "Usage: $0 [start|restart|graceful|graceful-stop|stop|status]"
    exit 1
fi

# Source utility functions.
source ${CART_DIR}/abstract/info/lib/util

# Import Environment Variables
for f in ~/.env/*; do
    . $f
done

# Validate user context.
validate_user_context.sh

# Handle commands.
case "$1" in
    start)               _start_node_service    ;;
    restart|graceful)    _restart_node_service  ;;
    graceful-stop|stop)  _stop_node_service     ;;
    status)              _status_node_service   ;;
esac

