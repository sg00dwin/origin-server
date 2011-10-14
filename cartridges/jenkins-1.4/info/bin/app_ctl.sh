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

. app_ctl_pre.sh

CART_CONF_DIR=/usr/libexec/li/cartridges/${OPENSHIFT_APP_TYPE}/info/configuration/etc/conf

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

case "$1" in
    start)
        if [ -f ${OPENSHIFT_APP_DIR}run/stop_lock ]
        then
            echo "Application is explicitly stopped!  Use 'rhc-ctl-app -a ${OPENSHIFT_APP_NAME} -c start' to start back up." 1>&2
            exit 0
        else
            if isrunning
            then
                echo "CLIENT_MESSAGE: Application($pid) is already running!" 1>&2
                exit 0
            fi
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
        fi
    ;;
    graceful-stop|stop)
        if [ -f $OPENSHIFT_RUN_DIR/jenkins.pid ]
        then
            if isrunning
            then
                if ! out=$(jenkins-cli quiet-down --username "$JENKINS_USERNAME" --password-file "${OPENSHIFT_HOMEDIR}.jenkins_password" 2>&1)
                then
                    # An error occurred quieting down jenkins
                    echo "CLIENT_MESSAGE: "
                    echo "CLIENT_MESSAGE: Could not quiet down Jenkins server '${OPENSHIFT_APP_NAME}':"
                    echo "CLIENT_MESSAGE:    $out"
                    echo "CLIENT_MESSAGE: "
                fi
                pid=`cat ${OPENSHIFT_RUN_DIR}jenkins.pid 2> /dev/null`
                kill -TERM $pid > /dev/null 2>&1
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
            fi
        fi
    ;;
    restart|graceful)
        action="restart"
        if "$1" == "graceful"
        then 
            action="safe-restart"
        fi
        if ! out=$(jenkins-cli $action --username "$JENKINS_USERNAME" --password-file "${OPENSHIFT_HOMEDIR}.jenkins_password" 2>&1)
        then
            # An error occurred restart jenkins
            echo "CLIENT_ERROR: "
            echo "CLIENT_ERROR: Failed restarting Jenkins server '${OPENSHIFT_APP_NAME}':"
            echo "CLIENT_ERROR:    $out"
            echo "CLIENT_ERROR: This might be expected if '${OPENSHIFT_APP_NAME}' isn't running."
            echo "CLIENT_ERROR: You can use 'rhc-ctl-app -a ${OPENSHIFT_APP_NAME} -c start' to start it first."
            echo "CLIENT_ERROR: "
            exit 1
        fi
    ;;
    reload)
        if ! out=$(jenkins-cli reload-configuration --username "$JENKINS_USERNAME" --password-file "${OPENSHIFT_HOMEDIR}.jenkins_password" 2>&1)
        then
            # An error occurred reloading jenkins configuration
            echo "CLIENT_ERROR: "
            echo "CLIENT_ERROR: Could not reload Jenkins server '${OPENSHIFT_APP_NAME}' configuration:"
            echo "CLIENT_ERROR:    $out"
            echo "CLIENT_ERROR: This might be expected if '${OPENSHIFT_APP_NAME}' isn't running."
            echo "CLIENT_ERROR: "
            exit 1
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
