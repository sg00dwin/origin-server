#!/bin/bash -e

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/abstract/info/lib/util

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


validate_user_context.sh

case "$1" in
    start)
        if [ -f ${OPENSHIFT_10GEN_MMS_AGENT_APP_DIR}run/stop_lock ]
        then
            echo "Application is explicitly stopped!  Use 'rhc-ctl-app -a ${OPENSHIFT_APP_NAME} -e start-10gen-mms-agent-0.1' to start back up." 1>&2
            exit 0
        else
            nohup python ${OPENSHIFT_10GEN_MMS_AGENT_APP_DIR}mms-agent/${OPENSHIFT_APP_UUID}_agent.py > ${OPENSHIFT_10GEN_MMS_AGENT_APP_DIR}logs/agent.log 2>&1 &
            echo $! > ${OPENSHIFT_10GEN_MMS_AGENT_APP_DIR}run/mms-agent.pid
        fi
    ;;

    graceful-stop|stop)
        mms_agent_pid=`cat ${OPENSHIFT_10GEN_MMS_AGENT_APP_DIR}run/mms-agent.pid 2> /dev/null`
        force_kill $mms_agent_pid
        wait_for_stop $mms_agent_pid
    ;;
esac
