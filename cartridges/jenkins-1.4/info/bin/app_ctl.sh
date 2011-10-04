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

case "$1" in
    start)
        /usr/lib/jvm/jre-1.6.0/bin/java \
            -Dcom.sun.akuma.Daemon=daemonized \
            -Djava.awt.headless=true \
            -DJENKINS_HOME=$OPENSHIFT_DATA_DIR/ \
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
    ;;
    graceful-stop|stop)
        kill -TERM $( cat $OPENSHIFT_RUN_DIR/jenkins.pid )
    ;;
    restart|graceful)
        $OPENSHIFT_APP_DIR/${OPENSHIFT_APP_NAME}_ctl.sh stop
        $OPENSHIFT_APP_DIR/${OPENSHIFT_APP_NAME}_ctl.sh start
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
