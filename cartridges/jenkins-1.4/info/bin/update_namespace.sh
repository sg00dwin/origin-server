#!/bin/bash

# Exit on any errors
set -e
#set -x

source "/etc/stickshift/stickshift-node.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util
CART_INFO_DIR=${CARTRIDGE_BASE_PATH}/jenkins-1.4/info

function print_help {
    echo "Usage: $0 app-name new_namespace old_namespace uuid"

    echo "$0 $@" | logger -p local0.notice -t stickshift_jenkins_update_namespace
    exit 1
}

[ $# -eq 4 ] || print_help

application="$1"
new_namespace="$2"
old_namespace="$3"
uuid=$4

setup_app_dir_vars
setup_user_vars

echo "export JENKINS_URL='https://${application}-${new_namespace}.${CLOUD_DOMAIN}/'" > $APP_HOME/.env/JENKINS_URL
. $APP_HOME/.env/OPENSHIFT_INTERNAL_IP
. $APP_HOME/.env/OPENSHIFT_INTERNAL_PORT
export JENKINS_URL="https://$OPENSHIFT_INTERNAL_IP:$OPENSHIFT_INTERNAL_PORT"
. $APP_HOME/.env/JENKINS_USERNAME
. $APP_HOME/.env/JENKINS_PASSWORD
. $APP_HOME/.env/OPENSHIFT_DATA_DIR

if ls $APP_DIR/data/jobs/*/config.xml > /dev/null 2>&1
then
    sed -i "s/-${old_namespace}.${CLOUD_DOMAIN}/-${new_namespace}.${CLOUD_DOMAIN}/g" $APP_DIR/data/jobs/*/config.xml
fi

if [ -f $APP_DIR/data/config.xml ]
then
    sed -i "s/-${old_namespace}.${CLOUD_DOMAIN}/-${new_namespace}.${CLOUD_DOMAIN}/g" $APP_DIR/data/config.xml
fi

if [ -f $APP_DIR/data/hudson.tasks.Mailer.xml ]
then
    sed -i "s/-${old_namespace}.${CLOUD_DOMAIN}/-${new_namespace}.${CLOUD_DOMAIN}/g" $APP_DIR/data/hudson.tasks.Mailer.xml
fi

if ! out=$(run_as_user "$CART_INFO_DIR/bin/jenkins_reload" 2>&1)
then
    # An error occurred reloading jenkins configuration
    client_message ""
    client_message "Could not reload Jenkins server '${application}' configuration:"
    client_message "   $out"
    client_message "This might be expected if '${application}' isn't running."
    client_message "Otherwise you might need to reload it with 'rhc app reload -a ${application}'"
    client_message "or by using the Jenkins interface:"
    client_message "https://${application}-${new_namespace}.${CLOUD_DOMAIN}/manage"
    client_message ""
fi

add_env_var "JENKINS_URL=https://${application}-${new_namespace}.${CLOUD_DOMAIN}/"

