#!/bin/bash -e

CART_DIR=/usr/libexec/li/cartridges
source ${CART_DIR}/li-controller/info/lib/util

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

. app_ctl_pre.sh

isrunning() {
    # Check for running app
    if [ -f ${OPENSHIFT_RUN_DIR}jenkins.pid ]
    then
      pid=`cat ${OPENSHIFT_RUN_DIR}jenkins.pid 2> /dev/null`
      if `ps --pid $pid > /dev/null 2>&1`
      then
        return 0
      fi
    fi
    # not running
    return 1
}

start_jenkins() {
    /usr/lib/jvm/jre-1.6.0/bin/java \
        -Dcom.sun.akuma.Daemon=daemonized \
        -Djava.awt.headless=true \
        -DJENKINS_HOME=$OPENSHIFT_DATA_DIR/ \
        -Dhudson.slaves.NodeProvisioner.recurrencePeriod=500 \
        -Dhudson.slaves.NodeProvisioner.initialDelay=100 \
        -Dhudson.slaves.NodeProvisioner.MARGIN=100 \
        -Xmx95m \
        -XX:MaxPermSize=85m \
        -jar /usr/lib/jenkins/jenkins.war \
        --ajp13Port=-1 \
        --controlPort=-1 \
        --logfile=$OPENSHIFT_LOG_DIR/jenkins.log \
        --daemon \
        --httpPort=8080 \
        --debug=5 \
        --handlerCountMax=45 \
        --handlerCountMaxIdle=20 \
        --httpListenAddress="$OPENSHIFT_INTERNAL_IP" &
    echo $! > "$OPENSHIFT_RUN_DIR/jenkins.pid"
}

case "$1" in
    start)
        if [ -f ${OPENSHIFT_APP_DIR}run/stop_lock ]
        then
            echo "Application is explicitly stopped!  Use 'rhc-ctl-app -a ${OPENSHIFT_APP_NAME} -c start' to start back up." 1>&2
            exit 0
        else
            if isrunning
            then
                echo "Application is already running!" 1>&2
                exit 0
            fi
            start_jenkins
        fi
    ;;
    graceful-stop|stop)
        if [ -f $OPENSHIFT_RUN_DIR/jenkins.pid ]
        then
            if isrunning
            then
                if "$1" == "graceful-stop"
                then
                    if ! out=$(jenkins-cli quiet-down --username "$JENKINS_USERNAME" --password-file "${OPENSHIFT_HOMEDIR}.jenkins_password" 2>&1)
                    then
                        # An error occurred quieting down jenkins
                        echo "Could not quiet down Jenkins server '${OPENSHIFT_APP_NAME}':" 1>&2
                        echo "   $out" 1>&2
                    fi
                fi
                pid=`cat ${OPENSHIFT_RUN_DIR}jenkins.pid 2> /dev/null`
                kill -TERM $pid > /dev/null 2>&1
                wait_for_stop $pid
            else
                echo "Application is already stopped!" 1>&2
                exit 0
            fi
        fi
    ;;
    restart|graceful)
        if isrunning
        then
            action="restart"
            if "$1" == "graceful"
            then 
                action="safe-restart"
            fi
            if ! out=$(jenkins-cli $action --username "$JENKINS_USERNAME" --password-file "${OPENSHIFT_HOMEDIR}.jenkins_password" 2>&1)
            then
                # An error occurred restart jenkins
                echo "Failed restarting Jenkins server '${OPENSHIFT_APP_NAME}':" 1>&2
                echo "   $out" 1>&2
                exit 1
            fi
        else
            start_jenkins
        fi
    ;;
    reload)
        if isrunning
        then
            if ! out=$(jenkins-cli reload-configuration --username "$JENKINS_USERNAME" --password-file "${OPENSHIFT_HOMEDIR}.jenkins_password" 2>&1)
            then
                # An error occurred reloading jenkins configuration
                echo "Could not reload Jenkins server '${OPENSHIFT_APP_NAME}' configuration:" 1>&2
                echo "   $out" 1>&2
                exit 1
            fi
        else
            echo "Application is stopped!" 1>&2
            exit 0
        fi
    ;;
    status)
        echo ""
        echo "Running Processes:"
        echo ""
        ps -eFCvx
        echo ""
        exit 0
    ;;
esac
